/*
 * Copyright (C) 2015-2016 Canonical, Ltd.
 *
 * This program is free software; you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation; version 3.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.
 */

#include "MirSurface.h"

#include <QDebug>
#include <QQmlEngine>

// local
#include "SurfaceManager.h"

#define MIRSURFACE_DEBUG 0

#if MIRSURFACE_DEBUG
#define DEBUG_MSG(params) qDebug().nospace() << "MirSurface[" << (void*)this << "," << m_name << "]::" << __func__  << " " << params
#define XDEBUG_MSG(params) qDebug().nospace() << "MirSurface[" << (void*)this << "," << m_name << "]::" << params

const char *stateToStr(Mir::State state)
{
    switch (state) {
    case Mir::UnknownState:
        return "unknown";
    case Mir::RestoredState:
        return "restored";
    case Mir::MinimizedState:
        return "minimized";
    case Mir::MaximizedState:
        return "maximized";
    case Mir::VertMaximizedState:
        return "vertMaximized";
    case Mir::FullscreenState:
        return "fullscreen";
    case Mir::HorizMaximizedState:
        return "horizMaximized";
    case Mir::MaximizedLeftState:
        return "maximizedLeft";
    case Mir::MaximizedRightState:
        return "maximizedRight";
    case Mir::MaximizedTopLeftState:
        return "maximizedTopLeft";
    case Mir::MaximizedTopRightState:
        return "maximizedTopRight";
    case Mir::MaximizedBottomLeftState:
        return "maximizedBottomLeft";
    case Mir::MaximizedBottomRightState:
        return "maximizedBottomRight";
    case Mir::HiddenState:
        return "hidden";
    default:
        return "???";
    }
}

#else
#define DEBUG_MSG(params) ((void)0)
#define XDEBUG_MSG(params) ((void)0)
#endif

using namespace unity::shell::application;

MirSurface::MirSurface(const QString& name,
        Mir::Type type,
        Mir::State state,
        MirSurface *parentSurface,
        const QUrl& screenshot,
        const QUrl &qmlFilePath)
    : unity::shell::application::MirSurfaceInterface(nullptr)
    , m_name(name)
    , m_type(type)
    , m_state(state)
    , m_orientationAngle(Mir::Angle0)
    , m_screenshotUrl(screenshot)
    , m_qmlFilePath(qmlFilePath)
    , m_live(true)
    , m_focused(false)
    , m_activeFocus(false)
    , m_width(-1)
    , m_height(-1)
    , m_slowToResize(false)
    , m_shellChrome(Mir::NormalChrome)
    , m_parentSurface(parentSurface)
    , m_childSurfaceList(new MirSurfaceListModel(this))
{
    DEBUG_MSG("state=" << stateToStr(state));

    QQmlEngine::setObjectOwnership(this, QQmlEngine::CppOwnership);

    m_delayedResizeTimer.setInterval(600);
    m_delayedResizeTimer.setSingleShot(true);
    connect(&m_delayedResizeTimer, &QTimer::timeout, this, &MirSurface::applyDelayedResize);

    m_zombieTimer.setInterval(100);
    m_zombieTimer.setSingleShot(true);
    connect(&m_zombieTimer, &QTimer::timeout, this, [this](){ this->setLive(false); });

    updateInputBoundsAfterResize();
}

MirSurface::~MirSurface()
{
    DEBUG_MSG("");

    // Early warning, while MirSurface methods can still be accessed.
    Q_EMIT destroyed(this);
}

QString MirSurface::name() const
{
    return m_name;
}

QString MirSurface::persistentId() const
{
    return m_name+"Id";
}

QString MirSurface::appId() const
{
    return m_name+"appId";
}
Mir::Type MirSurface::type() const
{
    return m_type;
}

Mir::State MirSurface::state() const
{
    return m_state;
}

void MirSurface::requestState(Mir::State state)
{
    if (state == m_state) {
        return;
    }
    DEBUG_MSG(stateToStr(state));
    Q_EMIT stateRequested(state);
}

void MirSurface::setState(Mir::State state)
{
    if (state == m_state) {
        return;
    }
    DEBUG_MSG(stateToStr(state));

    bool oldVisible = visible();

    m_state = state;
    Q_EMIT stateChanged(state);

    if (visible() != oldVisible) {
        XDEBUG_MSG("visibleChanged("<<visible()<<")");
        Q_EMIT visibleChanged(visible());
    }
}

bool MirSurface::live() const
{
    return m_live;
}

bool MirSurface::visible() const
{
    return m_state != Mir::MinimizedState && m_state != Mir::HiddenState;
}

void MirSurface::setLive(bool live)
{
    if (live == m_live)
        return;

    DEBUG_MSG(live);
    m_live = live;
    Q_EMIT liveChanged(live);

    if (!m_live && m_views.count() == 0) {
        deleteLater();
    }
}

QUrl MirSurface::qmlFilePath() const
{
    return m_qmlFilePath;
}

QUrl MirSurface::screenshotUrl() const
{
    return m_screenshotUrl;
}

void MirSurface::setScreenshotUrl(QUrl screenshotUrl)
{
    if (screenshotUrl == m_screenshotUrl)
        return;

    m_screenshotUrl = screenshotUrl;
    Q_EMIT screenshotUrlChanged(screenshotUrl);
}

Mir::OrientationAngle MirSurface::orientationAngle() const
{
    return m_orientationAngle;
}

void MirSurface::setOrientationAngle(Mir::OrientationAngle angle)
{
    if (angle == m_orientationAngle)
        return;

    m_orientationAngle = angle;
    Q_EMIT orientationAngleChanged(angle);
}

void MirSurface::setKeymap(const QString &value)
{
    if (value != m_keymap) {
        DEBUG_MSG(value);
        m_keymap = value;
        Q_EMIT keymapChanged(m_keymap);
    }
}

QString MirSurface::keymap() const
{
    return m_keymap;
}

Mir::ShellChrome MirSurface::shellChrome() const
{
    return m_shellChrome;
}

void MirSurface::setShellChrome(Mir::ShellChrome shellChrome)
{
    if (shellChrome == m_shellChrome)
        return;

    DEBUG_MSG(shellChrome);
    m_shellChrome = shellChrome;
    Q_EMIT shellChromeChanged(shellChrome);
}

void MirSurface::registerView(qintptr viewId)
{
    m_views.insert(viewId, MirSurface::View{false});
    DEBUG_MSG(viewId << " after=" << m_views.count());
}

void MirSurface::unregisterView(qintptr viewId)
{
    m_views.remove(viewId);
    DEBUG_MSG(viewId << " after=" << m_views.count() << " live=" << m_live);
    if (!m_live && m_views.count() == 0) {
        deleteLater();
    }
    updateExposure();
}

void MirSurface::setViewExposure(qintptr viewId, bool visible)
{
    if (!m_views.contains(viewId)) return;

    m_views[viewId].visible = visible;
    updateExposure();
}

void MirSurface::updateExposure()
{
    bool newExposure = false;
    QHashIterator<qintptr, View> i(m_views);
    while (i.hasNext()) {
        i.next();
        newExposure |= i.value().visible;
    }

    if (newExposure != m_exposed) {
        m_exposed = newExposure;
        DEBUG_MSG(m_exposed);
        Q_EMIT exposedChanged(m_exposed);
        updateInputBoundsAfterResize();
    }
}

bool MirSurface::activeFocus() const
{
    return m_activeFocus;
}

void MirSurface::setActiveFocus(bool value)
{
    if (m_activeFocus == value)
        return;

    m_activeFocus = value;

    Q_EMIT activeFocusChanged(value);

    if (m_activeFocus && !m_focused) {
        requestFocus();
    }
}

int MirSurface::width() const
{
    return m_width;
}

int MirSurface::height() const
{
    return m_height;
}

void MirSurface::resize(int width, int height)
{
    if (m_slowToResize) {
        if (!m_delayedResizeTimer.isActive()) {
            m_delayedResize.setWidth(width);
            m_delayedResize.setHeight(height);
            m_delayedResizeTimer.start();
        } else {
            m_pendingResize.setWidth(width);
            m_pendingResize.setHeight(height);
        }
    } else {
        doResize(width, height);
    }
}

void MirSurface::applyDelayedResize()
{
    doResize(m_delayedResize.width(), m_delayedResize.height());
    m_delayedResize.setWidth(-1);
    m_delayedResize.setHeight(-1);

    if (m_pendingResize.isValid()) {
        QSize size = m_pendingResize;
        m_pendingResize.setWidth(-1);
        m_pendingResize.setHeight(-1);
        resize(size.width(), size.height());
    }
}

void MirSurface::doResize(int width, int height)
{
    bool changed = false;

    if (width != m_width) {
        m_width = width;
        Q_EMIT widthChanged();
        changed = true;
    }

    if (m_height != height) {
        m_height = height;
        Q_EMIT heightChanged();
        changed = true;
    }

    if (changed) {
        XDEBUG_MSG("sizeChanged(width="<<width<<", height="<<height<<")");
        Q_EMIT sizeChanged(QSize(width, height));
    }

    updateInputBoundsAfterResize();
}

void MirSurface::updateInputBoundsAfterResize()
{
    setInputBounds(QRect(0, 0, m_width, m_height));
}

bool MirSurface::isSlowToResize() const
{
    return m_slowToResize;
}

void MirSurface::setSlowToResize(bool value)
{
    if (m_slowToResize != value) {
        DEBUG_MSG(value);
        m_slowToResize = value;
        Q_EMIT slowToResizeChanged();
        if (!m_slowToResize && m_delayedResizeTimer.isActive()) {
            m_delayedResizeTimer.stop();
            applyDelayedResize();
        }
    }
}

void MirSurface::setMinimumWidth(int value)
{
    if (value != m_minimumWidth) {
        m_minimumWidth = value;
        Q_EMIT minimumWidthChanged(m_minimumWidth);
    }
}

void MirSurface::setMaximumWidth(int value)
{
    if (value != m_maximumWidth) {
        m_maximumWidth = value;
        Q_EMIT maximumWidthChanged(m_maximumWidth);
    }
}

void MirSurface::setMinimumHeight(int value)
{
    if (value != m_minimumHeight) {
        m_minimumHeight = value;
        Q_EMIT minimumHeightChanged(m_minimumHeight);
    }
}

void MirSurface::setMaximumHeight(int value)
{
    if (value != m_maximumHeight) {
        m_maximumHeight = value;
        Q_EMIT maximumHeightChanged(m_maximumHeight);
    }
}

void MirSurface::setWidthIncrement(int value)
{
    if (value != m_widthIncrement) {
        m_widthIncrement = value;
        Q_EMIT widthIncrementChanged(m_widthIncrement);
    }
}

void MirSurface::setHeightIncrement(int value)
{
    if (value != m_heightIncrement) {
        m_heightIncrement = value;
        Q_EMIT heightIncrementChanged(m_heightIncrement);
    }
}

void MirSurface::close()
{
    DEBUG_MSG("");

    for (int i = 0; i < m_childSurfaceList->count(); ++i) {
        m_childSurfaceList->get(i)->close();
    }

    if (!m_zombieTimer.isActive()) {
        m_zombieTimer.start();
        Q_EMIT closeRequested();
    }
}

void MirSurface::activate()
{
    DEBUG_MSG("");
    SurfaceManager::instance()->activate(this);
}

void MirSurface::requestFocus()
{
    DEBUG_MSG("");
    Q_EMIT focusRequested();
}

void MirSurface::setFocused(bool value)
{
    if (m_focused == value)
        return;

    DEBUG_MSG("(" << value << ")");

    m_focused = value;
    Q_EMIT focusedChanged(value);
}

bool MirSurface::focused() const
{
    return m_focused;
}

QRect MirSurface::inputBounds() const
{
    return m_inputBounds;
}

void MirSurface::setInputBounds(const QRect &boundsRect)
{
    if (boundsRect != m_inputBounds) {
        m_inputBounds = boundsRect;
        DEBUG_MSG("(" << m_inputBounds << ")");
        Q_EMIT inputBoundsChanged(m_inputBounds);
    }
}

void MirSurface::openMenu(qreal x, qreal y, qreal width, qreal height)
{
    auto *menu = SurfaceManager::instance()->createSurface("menu", Mir::MenuType, Mir::HiddenState,
            this /* parentSurface */,
            QUrl() /* screenshot */,
            QUrl("qrc:///Unity/Application/KateMenu.qml"));

    menu->setRequestedPosition(QPoint(x,y));
    menu->resize(width, height);
    menu->requestState(Mir::RestoredState);

    SurfaceManager::instance()->notifySurfaceCreated(menu);
}

void MirSurface::openDialog(qreal x, qreal y, qreal width, qreal height)
{
    auto *dialog = SurfaceManager::instance()->createSurface("dialog", Mir::DialogType, Mir::HiddenState,
            this /* parentSurface */,
            QUrl() /* screenshot */,
            QUrl("qrc:///Unity/Application/KateDialog.qml"));

    dialog->setRequestedPosition(QPoint(x,y));
    dialog->resize(width, height);
    dialog->requestState(Mir::RestoredState);

    SurfaceManager::instance()->notifySurfaceCreated(dialog);

    dialog->requestFocus();
}

void MirSurface::setRequestedPosition(const QPoint &value)
{
    if (value != m_requestedPosition) {
        m_requestedPosition = value;
        Q_EMIT requestedPositionChanged(value);

        // fake-miral: always comply
        m_position = m_requestedPosition;
        XDEBUG_MSG("positionChanged("<<m_position<<")");
        Q_EMIT positionChanged(m_position);
    }
}

MirSurfaceInterface* MirSurface::parentSurface() const
{
    return m_parentSurface;
}

MirSurfaceListInterface* MirSurface::childSurfaceList() const
{
    return m_childSurfaceList;
}
