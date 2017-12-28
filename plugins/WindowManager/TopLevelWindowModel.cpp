/*
 * Copyright (C) 2016-2017 Canonical, Ltd.
 *
 * This program is free software: you can redistribute it and/or modify it under
 * the terms of the GNU Lesser General Public License version 3, as published by
 * the Free Software Foundation.
 *
 * This program is distributed in the hope that it will be useful, but WITHOUT
 * ANY WARRANTY; without even the implied warranties of MERCHANTABILITY,
 * SATISFACTORY QUALITY, or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
 * Lesser General Public License for more details.
 *
 * You should have received a copy of the GNU Lesser General Public License
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.
 */

#include "TopLevelWindowModel.h"

// unity-api
#include <unity/shell/application/ApplicationInfoInterface.h>
#include <unity/shell/application/ApplicationManagerInterface.h>
#include <unity/shell/application/MirSurfaceInterface.h>
#include <unity/shell/application/MirSurfaceListInterface.h>
#include <unity/shell/application/SurfaceManagerInterface.h>

// Qt
#include <QGuiApplication>
#include <QDebug>

// local
#include "Window.h"

Q_LOGGING_CATEGORY(TOPLEVELWINDOWMODEL, "toplevelwindowmodel", QtInfoMsg)

#define DEBUG_MSG qCDebug(TOPLEVELWINDOWMODEL).nospace().noquote() << __func__
#define INFO_MSG qCInfo(TOPLEVELWINDOWMODEL).nospace().noquote() << __func__

namespace unityapi = unity::shell::application;

TopLevelWindowModel::TopLevelWindowModel()
{
}

void TopLevelWindowModel::setApplicationManager(unityapi::ApplicationManagerInterface* value)
{
    if (m_applicationManager == value) {
        return;
    }

    DEBUG_MSG << "(" << value << ")";

    Q_ASSERT(m_modelState == IdleState);
    m_modelState = ResettingState;

    beginResetModel();

    if (m_applicationManager) {
        m_windowModel.clear();
        disconnect(m_applicationManager, 0, this, 0);
    }

    m_applicationManager = value;

    if (m_applicationManager) {
        connect(m_applicationManager, &QAbstractItemModel::rowsInserted,
                this, [this](const QModelIndex &/*parent*/, int first, int last) {
                    for (int i = first; i <= last; ++i) {
                        auto application = m_applicationManager->get(i);
                        addApplication(application);
                    }
                });

        connect(m_applicationManager, &QAbstractItemModel::rowsAboutToBeRemoved,
                this, [this](const QModelIndex &/*parent*/, int first, int last) {
                    for (int i = first; i <= last; ++i) {
                        auto application = m_applicationManager->get(i);
                        removeApplication(application);
                    }
                });

        for (int i = 0; i < m_applicationManager->rowCount(); ++i) {
            auto application = m_applicationManager->get(i);
            addApplication(application);
        }
    }

    endResetModel();
    m_modelState = IdleState;
}

void TopLevelWindowModel::setSurfaceManager(unityapi::SurfaceManagerInterface *surfaceManager)
{
    if (surfaceManager == m_surfaceManager) {
        return;
    }

    DEBUG_MSG << "(" << surfaceManager << ")";

    if (m_surfaceManager) {
        disconnect(m_surfaceManager, 0, this, 0);
    }

    m_surfaceManager = surfaceManager;

    if (m_surfaceManager) {
        connect(m_surfaceManager, &unityapi::SurfaceManagerInterface::surfaceCreated, this, &TopLevelWindowModel::onSurfaceCreated);
        connect(m_surfaceManager, &unityapi::SurfaceManagerInterface::surfacesRaised, this, &TopLevelWindowModel::onSurfacesRaised);
        connect(m_surfaceManager, &unityapi::SurfaceManagerInterface::modificationsStarted, this, &TopLevelWindowModel::onModificationsStarted);
        connect(m_surfaceManager, &unityapi::SurfaceManagerInterface::modificationsEnded, this, &TopLevelWindowModel::onModificationsEnded);
    }

    Q_EMIT surfaceManagerChanged(m_surfaceManager);
}

void TopLevelWindowModel::addApplication(unityapi::ApplicationInfoInterface *application)
{
    DEBUG_MSG << "(" << application->appId() << ")";

    if (application->state() != unityapi::ApplicationInfoInterface::Stopped && application->surfaceList()->count() == 0) {
        prependPlaceholder(application);
    }
}

void TopLevelWindowModel::removeApplication(unityapi::ApplicationInfoInterface *application)
{
    DEBUG_MSG << "(" << application->appId() << ")";

    Q_ASSERT(m_modelState == IdleState);

    int i = 0;
    while (i < m_windowModel.count()) {
        if (m_windowModel.at(i).application == application) {
            deleteAt(i);
        } else {
            ++i;
        }
    }
}

void TopLevelWindowModel::prependPlaceholder(unityapi::ApplicationInfoInterface *application)
{
    INFO_MSG << "(" << application->appId() << ")";

    prependSurfaceHelper(nullptr, application);
}

void TopLevelWindowModel::prependSurface(unityapi::MirSurfaceInterface *surface, unityapi::ApplicationInfoInterface *application)
{
    Q_ASSERT(surface != nullptr);

    connectSurface(surface);

    bool filledPlaceholder = false;
    for (int i = 0; i < m_windowModel.count() && !filledPlaceholder; ++i) {
        ModelEntry &entry = m_windowModel[i];
        if (entry.application == application && entry.window->surface() == nullptr) {
            entry.window->setSurface(surface);
            INFO_MSG << " appId=" << application->appId() << " surface=" << surface
                      << ", filling out placeholder. after: " << toString();
            filledPlaceholder = true;
        }
    }

    if (!filledPlaceholder) {
        INFO_MSG << " appId=" << application->appId() << " surface=" << surface << ", adding new row";
        prependSurfaceHelper(surface, application);
    }
}

void TopLevelWindowModel::prependSurfaceHelper(unityapi::MirSurfaceInterface *surface, unityapi::ApplicationInfoInterface *application)
{

    Window *window = createWindow(surface);

    connect(window, &Window::stateChanged, this, [=](Mir::State newState) {
        if (newState == Mir::HiddenState) {
            // Comply, removing it from our model. Just as if it didn't exist anymore.
            removeAt(indexForId(window->id()));
        } else {
            if (indexForId(window->id()) == -1) {
                // was probably hidden before. put it back on the list
                auto *application = m_applicationManager->findApplicationWithSurface(window->surface());
                Q_ASSERT(application);
                prependWindow(window, application);
            }
        }
    });

    prependWindow(window, application);

    if (!surface) {
        activateEmptyWindow(window);
    }

    INFO_MSG << " after " << toString();
}

void TopLevelWindowModel::prependWindow(Window *window, unityapi::ApplicationInfoInterface *application)
{
    if (m_modelState == IdleState) {
        m_modelState = InsertingState;
        beginInsertRows(QModelIndex(), 0 /*first*/, 0 /*last*/);
    } else {
        Q_ASSERT(m_modelState == ResettingState);
        // No point in signaling anything if we're resetting the whole model
    }

    m_windowModel.prepend(ModelEntry(window, application));

    if (m_modelState == InsertingState) {
        endInsertRows();
        Q_EMIT countChanged();
        Q_EMIT listChanged();
        m_modelState = IdleState;
    }
}

void TopLevelWindowModel::connectWindow(Window *window)
{
    connect(window, &Window::focusRequested, this, [this, window]() {
        if (!window->surface()) {
            activateEmptyWindow(window);
        }
    });

    connect(window, &Window::focusedChanged, this, [this, window](bool focused) {
        if (window->surface()) {
            // Condense changes to the focused window
            // eg: Do focusedWindow=A to focusedWindow=B instead of
            // focusedWindow=A to focusedWindow=null to focusedWindow=B
            if (focused) {
                Q_ASSERT(m_newlyFocusedWindow == nullptr);
                m_focusedWindowChanged = true;
                m_newlyFocusedWindow = window;
            } else if (m_focusedWindow == window) {
                m_focusedWindowChanged = true;
            } else {
                // don't clear the focused window if you were not there in the first place
                // happens when a filled window gets replaced with an empty one (no surface) as the focused window.
            }
        }
    });

    connect(window, &Window::closeRequested, this, [this, window]() {
        if (!window->surface()) {
            // do things ourselves as miral doesn't know about this window
            int id = window->id();
            int index = indexForId(id);
            bool focusOther = false;
            Q_ASSERT(index >= 0);
            if (window->focused()) {
                focusOther = true;
            }
            m_windowModel[index].application->close();
            if (focusOther) {
                activateTopMostWindowWithoutId(id);
            }
        }
    });

    connect(window, &Window::emptyWindowActivated, this, [this, window]() {
        activateEmptyWindow(window);
    });

    connect(window, &Window::liveChanged, this, [this, window](bool isAlive) {
        if (!isAlive && window->state() == Mir::HiddenState) {
            // Hidden windows are not in the model. So just delete it right away.
            delete window;
        }
    });
}

void TopLevelWindowModel::activateEmptyWindow(Window *window)
{
    Q_ASSERT(!window->surface());
    DEBUG_MSG << "(" << window << ")";

    // miral doesn't know about empty windows (ie, windows that are not backed up by MirSurfaces)
    // So we have to activate them ourselves (instead of asking SurfaceManager to do it for us).

    window->setFocused(true);
    raiseId(window->id());
    Window *previousWindow = m_focusedWindow;
    setFocusedWindow(window);
    if (previousWindow && previousWindow->surface() && previousWindow->surface()->focused()) {
        m_surfaceManager->activate(nullptr);
    }
}

void TopLevelWindowModel::connectSurface(unityapi::MirSurfaceInterface *surface)
{
    connect(surface, &unityapi::MirSurfaceInterface::liveChanged, this, [this, surface](bool live){
            if (!live) {
                onSurfaceDied(surface);
            }
        });
    connect(surface, &QObject::destroyed, this, [this, surface](){ this->onSurfaceDestroyed(surface); });
}

void TopLevelWindowModel::onSurfaceDied(unityapi::MirSurfaceInterface *surface)
{
    if (surface->type() == Mir::InputMethodType) {
        removeInputMethodWindow();
        return;
    }

    int i = indexOf(surface);
    if (i == -1) {
        return;
    }

    auto application = m_windowModel[i].application;

    // can't be starting if it already has a surface
    Q_ASSERT(application->state() != unityapi::ApplicationInfoInterface::Starting);

    if (application->state() == unityapi::ApplicationInfoInterface::Running) {
        m_windowModel[i].removeOnceSurfaceDestroyed = true;
    } else {
        // assume it got killed by the out-of-memory daemon.
        //
        // So leave entry in the model and only remove its surface, so shell can display a screenshot
        // in its place.
        m_windowModel[i].removeOnceSurfaceDestroyed = false;
    }
}

void TopLevelWindowModel::onSurfaceDestroyed(unityapi::MirSurfaceInterface *surface)
{
    int i = indexOf(surface);
    if (i == -1) {
        return;
    }

    if (m_windowModel[i].removeOnceSurfaceDestroyed) {
        deleteAt(i);
    } else {
        auto window = m_windowModel[i].window;
        window->setSurface(nullptr);
        window->setFocused(false);
        INFO_MSG << " Removed surface from entry. After: " << toString();
    }
}

Window *TopLevelWindowModel::createWindow(unityapi::MirSurfaceInterface *surface)
{
    int id = generateId();
    Window *qmlWindow = new Window(id, this);
    connectWindow(qmlWindow);
    if (surface) {
        qmlWindow->setSurface(surface);
    }
    return qmlWindow;
}

void TopLevelWindowModel::onSurfaceCreated(unityapi::MirSurfaceInterface *surface)
{
    DEBUG_MSG << "(" << surface << ")";

    if (surface->parentSurface()) {
        // Wrap it in a Window so that we keep focusedWindow() up to date.
        Window *window = createWindow(surface);
        connect(surface, &QObject::destroyed, window, [=](){
            window->setSurface(nullptr);
            window->deleteLater();
        });
    } else {
        if (surface->type() == Mir::InputMethodType) {
            connectSurface(surface);
            setInputMethodWindow(createWindow(surface));
        } else {
            auto *application = m_applicationManager->findApplicationWithSurface(surface);
            if (application) {
                if (surface->state() == Mir::HiddenState) {
                    // Ignore it until it's finally shown
                    connect(surface, &unityapi::MirSurfaceInterface::stateChanged, this, [=](Mir::State newState) {
                        Q_ASSERT(newState != Mir::HiddenState);
                        disconnect(surface, &unityapi::MirSurfaceInterface::stateChanged, this, 0);
                        prependSurface(surface, application);
                    });
                } else {
                    prependSurface(surface, application);
                }
            } else {
                // Must be a prompt session. No need to do add it as a prompt surface is not top-level.
                // It will show up in the ApplicationInfoInterface::promptSurfaceList of some application.
                // Still wrap it in a Window though, so that we keep focusedWindow() up to date.
                Window *promptWindow = createWindow(surface);
                connect(surface, &QObject::destroyed, promptWindow, [=](){
                    promptWindow->setSurface(nullptr);
                    promptWindow->deleteLater();
                });
            }
        }
    }
}

void TopLevelWindowModel::deleteAt(int index)
{
    auto window = m_windowModel[index].window;

    removeAt(index);

    window->setSurface(nullptr);

    delete window;
}

void TopLevelWindowModel::removeAt(int index)
{
    if (m_modelState == IdleState) {
        beginRemoveRows(QModelIndex(), index, index);
        m_modelState = RemovingState;
    } else {
        Q_ASSERT(m_modelState == ResettingState);
        // No point in signaling anything if we're resetting the whole model
    }

    auto window = m_windowModel[index].window;

    if (!window->surface()) {
        window->setFocused(false);
    }

    m_windowModel.removeAt(index);

    if (m_modelState == RemovingState) {
        endRemoveRows();
        Q_EMIT countChanged();
        Q_EMIT listChanged();
        m_modelState = IdleState;
    }

    if (m_focusedWindow == window) {
        setFocusedWindow(nullptr);
    }

    INFO_MSG << " after " << toString();
}

void TopLevelWindowModel::setInputMethodWindow(Window *window)
{
    if (m_inputMethodWindow) {
        qWarning("Multiple Input Method Surfaces created, removing the old one!");
        delete m_inputMethodWindow;
    }
    m_inputMethodWindow = window;
    Q_EMIT inputMethodSurfaceChanged(m_inputMethodWindow->surface());
}

void TopLevelWindowModel::removeInputMethodWindow()
{
    if (m_inputMethodWindow) {
        delete m_inputMethodWindow;
        m_inputMethodWindow = nullptr;
        Q_EMIT inputMethodSurfaceChanged(nullptr);
    }
}

void TopLevelWindowModel::onSurfacesRaised(const QVector<unityapi::MirSurfaceInterface*> &surfaces)
{
    DEBUG_MSG << "(" << surfaces << ")";
    const int raiseCount = surfaces.size();
    for (int i = 0; i < raiseCount; i++) {
        int fromIndex = findIndexOf(surfaces[i]);
        if (fromIndex != -1) {
            move(fromIndex, 0);
        }
    }
}

int TopLevelWindowModel::rowCount(const QModelIndex &/*parent*/) const
{
    return m_windowModel.count();
}

QVariant TopLevelWindowModel::data(const QModelIndex& index, int role) const
{
    if (index.row() < 0 || index.row() >= m_windowModel.size())
        return QVariant();

    if (role == WindowRole) {
        Window *window = m_windowModel.at(index.row()).window;
        return QVariant::fromValue(window);
    } else if (role == ApplicationRole) {
        return QVariant::fromValue(m_windowModel.at(index.row()).application);
    } else {
        return QVariant();
    }
}

int TopLevelWindowModel::findIndexOf(const unityapi::MirSurfaceInterface *surface) const
{
    for (int i=0; i<m_windowModel.count(); i++) {
        if (m_windowModel[i].window->surface() == surface) {
            return i;
        }
    }
    return -1;
}

int TopLevelWindowModel::generateId()
{
    int id = m_nextId;
    m_nextId = nextFreeId(nextId(id), id);
    return id;
}

int TopLevelWindowModel::nextId(int id) const
{
    if (id == m_maxId) {
        return id = 1;
    } else {
        return id + 1;
    }
}

int TopLevelWindowModel::nextFreeId(int candidateId, const int latestId)
{
    int firstCandidateId = candidateId;

    while (indexForId(candidateId) != -1 || candidateId == latestId) {
        candidateId = nextId(candidateId);

        if (candidateId == firstCandidateId) {
            qFatal("TopLevelWindowModel: run out of window ids.");
        }
    }

    return candidateId;
}

QString TopLevelWindowModel::toString()
{
    QString str;
    for (int i = 0; i < m_windowModel.count(); ++i) {
        auto item = m_windowModel.at(i);

        QString itemStr = QString("(index=%1,appId=%2,surface=0x%3,id=%4)")
            .arg(QString::number(i),
                 item.application->appId(),
                 QString::number((qintptr)item.window->surface(), 16),
                 QString::number(item.window->id()));

        if (i > 0) {
            str.append(",");
        }
        str.append(itemStr);
    }
    return str;
}

int TopLevelWindowModel::indexOf(unityapi::MirSurfaceInterface *surface)
{
    for (int i = 0; i < m_windowModel.count(); ++i) {
        if (m_windowModel.at(i).window->surface() == surface) {
            return i;
        }
    }
    return -1;
}

int TopLevelWindowModel::indexForId(int id) const
{
    for (int i = 0; i < m_windowModel.count(); ++i) {
        if (m_windowModel[i].window->id() == id) {
            return i;
        }
    }
    return -1;
}

Window *TopLevelWindowModel::windowAt(int index) const
{
    if (index >=0 && index < m_windowModel.count()) {
        return m_windowModel[index].window;
    } else {
        return nullptr;
    }
}

unityapi::MirSurfaceInterface *TopLevelWindowModel::surfaceAt(int index) const
{
    if (index >=0 && index < m_windowModel.count()) {
        return m_windowModel[index].window->surface();
    } else {
        return nullptr;
    }
}

unityapi::ApplicationInfoInterface *TopLevelWindowModel::applicationAt(int index) const
{
    if (index >=0 && index < m_windowModel.count()) {
        return m_windowModel[index].application;
    } else {
        return nullptr;
    }
}

int TopLevelWindowModel::idAt(int index) const
{
    if (index >=0 && index < m_windowModel.count()) {
        return m_windowModel[index].window->id();
    } else {
        return 0;
    }
}

void TopLevelWindowModel::raiseId(int id)
{
    if (m_modelState == IdleState) {
        DEBUG_MSG << "(id=" << id << ") - do it now.";
        doRaiseId(id);
    } else {
        DEBUG_MSG << "(id=" << id << ") - Model busy (modelState=" << m_modelState << "). Try again in the next event loop.";
        // The model has just signalled some change. If we have a Repeater responding to this update, it will get nuts
        // if we perform yet another model change straight away.
        //
        // A bad sympton of this problem is a Repeater.itemAt(index) call returning null event though Repeater.count says
        // the index is definitely within bounds.
        QMetaObject::invokeMethod(this, "raiseId", Qt::QueuedConnection, Q_ARG(int, id));
    }
}

void TopLevelWindowModel::doRaiseId(int id)
{
    int fromIndex = indexForId(id);
    // can't raise something that doesn't exist or that it's already on top
    if (fromIndex != -1 && fromIndex != 0) {
        auto surface = m_windowModel[fromIndex].window->surface();
        if (surface) {
            m_surfaceManager->raise(surface);
        } else {
            // move it ourselves. Since there's no mir::scene::Surface/miral::Window, there's nothing
            // miral can do about it.
            move(fromIndex, 0);
        }
    }
}

void TopLevelWindowModel::setFocusedWindow(Window *window)
{
    if (window != m_focusedWindow) {
        INFO_MSG << "(" << window << ")";

        Window* previousWindow = m_focusedWindow;

        m_focusedWindow = window;
        Q_EMIT focusedWindowChanged(m_focusedWindow);

        if (previousWindow && previousWindow->focused() && !previousWindow->surface()) {
            // do it ourselves. miral doesn't know about this window
            previousWindow->setFocused(false);
        }
    }
}

unityapi::MirSurfaceInterface* TopLevelWindowModel::inputMethodSurface() const
{
    return m_inputMethodWindow ? m_inputMethodWindow->surface() : nullptr;
}

Window* TopLevelWindowModel::focusedWindow() const
{
    return m_focusedWindow;
}

void TopLevelWindowModel::move(int from, int to)
{
    if (from == to) return;
    DEBUG_MSG << " from=" << from << " to=" << to;

    if (from >= 0 && from < m_windowModel.size() && to >= 0 && to < m_windowModel.size()) {
        QModelIndex parent;
        /* When moving an item down, the destination index needs to be incremented
           by one, as explained in the documentation:
           http://qt-project.org/doc/qt-5.0/qtcore/qabstractitemmodel.html#beginMoveRows */

        Q_ASSERT(m_modelState == IdleState);
        m_modelState = MovingState;

        beginMoveRows(parent, from, from, parent, to + (to > from ? 1 : 0));
#if QT_VERSION < QT_VERSION_CHECK(5, 6, 0)
        const auto &window = m_windowModel.takeAt(from);
        m_windowModel.insert(to, window);
#else
        m_windowModel.move(from, to);
#endif
        endMoveRows();

        Q_EMIT listChanged();
        m_modelState = IdleState;

        INFO_MSG << " after " << toString();
    }
}
void TopLevelWindowModel::onModificationsStarted()
{
}

void TopLevelWindowModel::onModificationsEnded()
{
    if (m_focusedWindowChanged) {
        setFocusedWindow(m_newlyFocusedWindow);
    }
    // reset
    m_focusedWindowChanged = false;
    m_newlyFocusedWindow = nullptr;
}

void TopLevelWindowModel::activateTopMostWindowWithoutId(int forbiddenId)
{
    DEBUG_MSG << "(" << forbiddenId << ")";

    for (int i = 0; i < m_windowModel.count(); ++i) {
        Window *window = m_windowModel[i].window;
        if (window->id() != forbiddenId) {
            window->activate();
        }
    }
}
