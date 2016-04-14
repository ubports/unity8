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
#include "Session.h"
#include "SessionManager.h"

#include <paths.h>

#include <QGuiApplication>
#include <QQuickItem>
#include <QQuickView>
#include <QQmlComponent>
#include <QTimer>

ApplicationInfo::ApplicationInfo(const QString &appId, QObject *parent)
    : ApplicationInfoInterface(appId, parent)
    , m_appId(appId)
    , m_stage(MainStage)
    , m_state(Stopped)
    , m_focused(false)
    , m_fullscreen(false)
    , m_session(0)
    , m_supportedOrientations(Qt::PortraitOrientation |
            Qt::LandscapeOrientation |
            Qt::InvertedPortraitOrientation |
            Qt::InvertedLandscapeOrientation)
    , m_rotatesWindowContents(false)
    , m_requestedState(RequestedRunning)
    , m_isTouchApp(true)
    , m_exemptFromLifecycle(false)
    , m_manualSurfaceCreation(false)
    , m_shellChrome(Mir::NormalChrome)
{
}

ApplicationInfo::ApplicationInfo(QObject *parent)
    : ApplicationInfoInterface(QString(), parent)
    , m_stage(MainStage)
    , m_state(Stopped)
    , m_focused(false)
    , m_fullscreen(false)
    , m_session(0)
    , m_supportedOrientations(Qt::PortraitOrientation |
            Qt::LandscapeOrientation |
            Qt::InvertedPortraitOrientation |
            Qt::InvertedLandscapeOrientation)
    , m_rotatesWindowContents(false)
    , m_requestedState(RequestedRunning)
    , m_isTouchApp(true)
    , m_exemptFromLifecycle(false)
    , m_manualSurfaceCreation(false)
    , m_shellChrome(Mir::NormalChrome)
{
}

ApplicationInfo::~ApplicationInfo()
{
    delete m_session;
}

void ApplicationInfo::createSession()
{
    if (m_session || state() == ApplicationInfo::Stopped) { return; }

    setSession(SessionManager::singleton()->createSession(appId(), m_screenshotFileName));
}

void ApplicationInfo::destroySession()
{
    Session *session = this->session();
    setSession(nullptr);
    delete session;
}

void ApplicationInfo::setSession(Session* session)
{
    if (m_session == session)
        return;

    if (m_session) {
        disconnect(this, 0, m_session, 0);
        m_session->setApplication(nullptr);
        m_session->setParent(nullptr);
        Q_EMIT m_session->deregister();
    }

    m_session = session;

    if (m_session) {
        m_session->setApplication(this);
        m_session->setParent(this);
        m_session->setFullscreen(m_fullscreen);
        SessionManager::singleton()->registerSession(m_session);
        connect(m_session, &Session::surfaceAdded,
                this, &ApplicationInfo::onSessionSurfaceAdded);
        connect(m_session, &Session::fullscreenChanged, this, &ApplicationInfo::fullscreenChanged);

        if (!m_manualSurfaceCreation) {
            QTimer::singleShot(500, m_session, &Session::createSurface);
        }
    }

    Q_EMIT sessionChanged(m_session);
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

        if (m_session) {
            m_session->setScreenshot(screenshotFileName);
        }
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

void ApplicationInfo::setStage(Stage value)
{
    if (value != m_stage) {
        m_stage = value;
        Q_EMIT stageChanged(value);
    }
}

void ApplicationInfo::setState(State value)
{
    if (value != m_state) {
        m_state = value;
        Q_EMIT stateChanged(value);

        if (!m_manualSurfaceCreation && !m_session && m_state == ApplicationInfo::Starting) {
            QTimer::singleShot(500, this, &ApplicationInfo::createSession);
        } else if (m_state == ApplicationInfo::Stopped) {
            Session *session = m_session;
            setSession(nullptr);
            delete session;
        }
    }
}

void ApplicationInfo::setFocused(bool value)
{
    if (value != m_focused) {
        m_focused = value;
        Q_EMIT focusedChanged(value);
    }
}

void ApplicationInfo::setFullscreen(bool value)
{
    m_fullscreen = value;
    if (m_session) {
        m_session->setFullscreen(value);
    }
}

bool ApplicationInfo::fullscreen() const
{
    return m_session ? m_session->fullscreen() : m_fullscreen;
}

void ApplicationInfo::setManualSurfaceCreation(bool value)
{
    if (value != m_manualSurfaceCreation) {
        m_manualSurfaceCreation = value;
        Q_EMIT manualSurfaceCreationChanged(value);
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
    if (m_requestedState != value) {
        m_requestedState = value;
        Q_EMIT requestedStateChanged(m_requestedState);

        if (m_requestedState == RequestedRunning && m_state == Suspended) {
            setState(Running);
        } else if (m_requestedState == RequestedSuspended && m_state == Running) {
            setState(Suspended);
        }
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

void ApplicationInfo::onSessionSurfaceAdded(MirSurface* surface)
{
    if (surface != nullptr && m_state == Starting) {
        if (m_requestedState == RequestedRunning) {
            setState(Running);
        } else {
            setState(Suspended);
        }
        surface->setShellChrome(m_shellChrome);
    }
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
    if (m_session && m_session->lastSurface()) {
        m_session->lastSurface()->setShellChrome(shellChrome);
    }
}
