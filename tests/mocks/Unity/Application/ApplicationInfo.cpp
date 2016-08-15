/*
 * Copyright (C) 2013-2016 Canonical, Ltd.
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

#include "ApplicationInfo.h"
#include "MirSurface.h"
#include "SurfaceManager.h"

#include <paths.h>

#include <QGuiApplication>
#include <QQuickItem>
#include <QQuickView>
#include <QQmlComponent>

#define APPLICATION_DEBUG 0

#if APPLICATION_DEBUG
#define DEBUG_MSG(params) qDebug().nospace() << "Application["<<appId()<<"]::" << __func__  << " " << params

QString stateToStr(ApplicationInfo::State state)
{
    switch (state) {
    case ApplicationInfo::Starting:
        return "starting";
    case ApplicationInfo::Running:
        return "running";
    case ApplicationInfo::Suspended:
        return "suspended";
    case ApplicationInfo::Stopped:
        return "stopped";
    default:
        return "???";
    };
}

#else
#define DEBUG_MSG(params) ((void)0)
#endif

#define WARNING_MSG(params) qWarning().nospace() << "Application["<<appId()<<"]::" << __func__  << " " << params

ApplicationInfo::ApplicationInfo(const QString &appId, QObject *parent)
    : ApplicationInfoInterface(appId, parent)
    , m_appId(appId)
    , m_surfaceList(new MirSurfaceListModel(this))
    , m_promptSurfaceList(new MirSurfaceListModel(this))
{
    connect(m_surfaceList, &MirSurfaceListModel::countChanged,
        this, &ApplicationInfo::onSurfaceCountChanged, Qt::QueuedConnection);

    m_surfaceCreationTimer.setSingleShot(true);
    m_surfaceCreationTimer.setInterval(500);
    connect(&m_surfaceCreationTimer, &QTimer::timeout, this, &ApplicationInfo::createSurface);
}

ApplicationInfo::ApplicationInfo(QObject *parent)
    : ApplicationInfo(QString(), parent)
{
}

ApplicationInfo::~ApplicationInfo()
{
}

void ApplicationInfo::createSurface()
{
    if (state() == ApplicationInfo::Stopped) { return; }

    QString surfaceName = name();
    if (m_surfaceList->count() > 0) {
        surfaceName.append(QString(" %1").arg(m_surfaceList->count()+1));
    }

    auto surfaceManager = SurfaceManager::instance();
    if (!surfaceManager) {
        WARNING_MSG("No SurfaceManager");
        return;
    }

    auto surface = surfaceManager->createSurface(surfaceName,
           Mir::NormalType,
           fullscreen() ? Mir::FullscreenState : Mir::MaximizedState,
           m_screenshotFileName);

    surface->setShellChrome(m_shellChrome);

    m_surfaceList->appendSurface(surface);

    ++m_liveSurfaceCount;
    connect(surface, &MirSurface::liveChanged, this, [this, surface](){
        if (!surface->live()) {
            --m_liveSurfaceCount;
            if (m_liveSurfaceCount == 0) {
                if (m_closingSurfaces.contains(surface)
                        || (m_state == Running && m_requestedState == RequestedRunning)) {
                    Q_EMIT closed();
                }
                setState(Stopped);
            } else {
                if (m_closingSurfaces.contains(surface) && m_requestedState == RequestedSuspended
                        && m_closingSurfaces.count() == 1) {
                    setState(Suspended);
                }
            }
            m_closingSurfaces.removeAll(surface);
        }
    });
    connect(surface, &MirSurface::closeRequested, this, [this, surface](){
        m_closingSurfaces.append(surface);
        if (m_state == Suspended) {
            // resume to allow application to close its surface
            setState(Running);
        }
    });
    connect(surface, &MirSurface::focusRequested, this, &ApplicationInfo::focusRequested);

    if (m_state == Starting) {
        if (m_requestedState == RequestedRunning) {
            setState(Running);
        } else {
            setState(Suspended);
        }
    }
}

void ApplicationInfo::setIconId(const QString &iconId)
{
    setIcon(QString("../../tests/graphics/applicationIcons/%2@18.png")
            .arg(iconId));
}

void ApplicationInfo::setScreenshotId(const QString &screenshotId)
{
    QString screenshotFileName;

    if (screenshotId.endsWith(".svg")) {
        screenshotFileName = QString("qrc:///Unity/Application/screenshots/%2")
            .arg(screenshotId);
    } else {
        screenshotFileName = QString("qrc:///Unity/Application/screenshots/%2@12.png")
            .arg(screenshotId);
    }

    if (screenshotFileName != m_screenshotFileName) {
        m_screenshotFileName = screenshotFileName;
    }
}

void ApplicationInfo::setName(const QString &value)
{
    if (value != m_name) {
        m_name = value;
        Q_EMIT nameChanged(value);
    }
}

void ApplicationInfo::setIcon(const QUrl &value)
{
    if (value != m_icon) {
        m_icon = value;
        Q_EMIT iconChanged(value);
    }
}

void ApplicationInfo::setState(State value)
{
    if (value != m_state) {
        DEBUG_MSG(qPrintable(stateToStr(value)));
        if (!m_manualSurfaceCreation && value == ApplicationInfo::Starting) {
            Q_ASSERT(m_surfaceList->count() == 0);
            m_surfaceCreationTimer.start();
        } else if (value == ApplicationInfo::Stopped) {
            m_surfaceCreationTimer.stop();
            for (int i = 0; i < m_surfaceList->count(); ++i) {
                MirSurface *surface = static_cast<MirSurface*>(m_surfaceList->get(i));
                surface->setLive(false);
            }
            for (int i = 0; i < m_promptSurfaceList->count(); ++i) {
                auto surface = static_cast<MirSurface*>(m_promptSurfaceList->get(i));
                surface->setLive(false);
            }
        }

        m_state = value;
        Q_EMIT stateChanged(value);
    }
}

void ApplicationInfo::close()
{
    DEBUG_MSG("");

    if (m_surfaceList->count() > 0) {
        for (int i = 0; i < m_surfaceList->count(); ++i) {
            MirSurface *surface = static_cast<MirSurface*>(m_surfaceList->get(i));
            surface->close();
        }
    } else {
        setState(Stopped);
        Q_EMIT closed();
    }
}

void ApplicationInfo::setFullscreen(bool value)
{
    m_fullscreen = value;
    if (m_surfaceList->rowCount() > 0) {
        m_surfaceList->get(0)->setState(Mir::FullscreenState);
    }
}

bool ApplicationInfo::fullscreen() const
{
    if (m_surfaceList->rowCount() > 0) {
        return m_surfaceList->get(0)->state() == Mir::FullscreenState;
    } else {
        return m_fullscreen;
    }
}

void ApplicationInfo::setManualSurfaceCreation(bool value)
{
    if (value != m_manualSurfaceCreation) {
        m_manualSurfaceCreation = value;
        Q_EMIT manualSurfaceCreationChanged(value);

        if (m_manualSurfaceCreation && m_surfaceCreationTimer.isActive()) {
            m_surfaceCreationTimer.stop();
        }
    }
}

Qt::ScreenOrientations ApplicationInfo::supportedOrientations() const
{
    return m_supportedOrientations;
}

void ApplicationInfo::setSupportedOrientations(Qt::ScreenOrientations orientations)
{
    m_supportedOrientations = orientations;
}

bool ApplicationInfo::rotatesWindowContents() const
{
    return m_rotatesWindowContents;
}

void ApplicationInfo::setRotatesWindowContents(bool value)
{
    m_rotatesWindowContents = value;
}

ApplicationInfo::RequestedState ApplicationInfo::requestedState() const
{
    return m_requestedState;
}

void ApplicationInfo::setRequestedState(RequestedState value)
{
    if (m_requestedState == value) {
        return;
    }
    DEBUG_MSG((value == RequestedRunning ? "RequestedRunning" : "RequestedSuspended") );

    m_requestedState = value;
    Q_EMIT requestedStateChanged(m_requestedState);

    if (m_requestedState == RequestedRunning) {

        if (m_state == Suspended) {
            Q_ASSERT(m_liveSurfaceCount > 0);
            setState(Running);
        } else if (m_state == Stopped) {
            Q_ASSERT(m_liveSurfaceCount == 0);
            // it's restarting
            setState(Starting);
        }

    } else if (m_requestedState == RequestedSuspended && m_state == Running
            && m_closingSurfaces.isEmpty()) {
        setState(Suspended);
    }
}

bool ApplicationInfo::isTouchApp() const
{
    return m_isTouchApp;
}

void ApplicationInfo::setIsTouchApp(bool isTouchApp)
{
    m_isTouchApp = isTouchApp;
}

bool ApplicationInfo::exemptFromLifecycle() const
{
    return m_exemptFromLifecycle;
}

void ApplicationInfo::setExemptFromLifecycle(bool exemptFromLifecycle)
{
    if (m_exemptFromLifecycle != exemptFromLifecycle)
    {
        m_exemptFromLifecycle = exemptFromLifecycle;
        Q_EMIT exemptFromLifecycleChanged(m_exemptFromLifecycle);
    }
}

QSize ApplicationInfo::initialSurfaceSize() const
{
    return m_initialSurfaceSize;
}

void ApplicationInfo::setInitialSurfaceSize(const QSize &size)
{
    if (size != m_initialSurfaceSize) {
        m_initialSurfaceSize = size;
        Q_EMIT initialSurfaceSizeChanged(m_initialSurfaceSize);
    }
}

void ApplicationInfo::setShellChrome(Mir::ShellChrome shellChrome)
{
    m_shellChrome = shellChrome;
    if (m_surfaceList->rowCount() > 0) {
        static_cast<MirSurface*>(m_surfaceList->get(0))->setShellChrome(shellChrome);
    }
}

bool ApplicationInfo::focused() const
{
    bool someSurfaceHasFocus = false; // to be proven wrong
    for (int i = 0; i < m_surfaceList->count() && !someSurfaceHasFocus; ++i) {
        someSurfaceHasFocus = m_surfaceList->get(i)->focused();
    }
    return someSurfaceHasFocus;
}

void ApplicationInfo::setFocused(bool value)
{
    if (focused() == value) {
        return;
    }

    if (value) {
        if (m_surfaceList->count() > 0) {
            m_surfaceList->get(0)->requestFocus();
        }
    } else {
        for (int i = 0; i < m_surfaceList->count(); ++i) {
            MirSurface *surface = static_cast<MirSurface*>(m_surfaceList->get(i));
            if (surface->focused()) {
                surface->setFocused(false);
            }
        }
    }
}

void ApplicationInfo::onSurfaceCountChanged()
{
    if (m_surfaceList->count() == 0 && m_state == Running) {
        setState(Stopped);
    }
}

void ApplicationInfo::requestFocus()
{
    if (m_surfaceList->count() == 0) {
        Q_EMIT focusRequested();
    } else {
        m_surfaceList->get(0)->requestFocus();
    }
}
