/*
 * Copyright (C) 2013-2015 Canonical, Ltd.
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
    , m_manualSurfaceCreation(false)
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
    , m_manualSurfaceCreation(false)
{
}

ApplicationInfo::~ApplicationInfo()
{
    delete m_session;
}

void ApplicationInfo::createSession()
{
    if (m_session || state() == ApplicationInfo::Stopped) { return; }

    QUrl screenshotUrl = QString("file://%1").arg(m_screenshotFileName);
    setSession(SessionManager::singleton()->createSession(appId(), screenshotUrl));
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
        SessionManager::singleton()->registerSession(m_session);
        connect(m_session, &Session::surfaceChanged,
                this, &ApplicationInfo::onSessionSurfaceChanged);

        if (!m_manualSurfaceCreation) {
            QTimer::singleShot(500, m_session, &Session::createSurface);
        }
    }

    Q_EMIT sessionChanged(m_session);
}

void ApplicationInfo::setIconId(const QString &iconId)
{
    setIcon(QString("file://%1/graphics/applicationIcons/%2@18.png")
            .arg(qmlDirectory())
            .arg(iconId));
}

void ApplicationInfo::setScreenshotId(const QString &screenshotId)
{
    QString screenshotFileName;

    if (screenshotId.endsWith(".svg")) {
        screenshotFileName = QString("%1/Dash/graphics/phone/screenshots/%2")
            .arg(qmlDirectory())
            .arg(screenshotId);
    } else {
        screenshotFileName = QString("%1/Dash/graphics/phone/screenshots/%2@12.png")
            .arg(qmlDirectory())
            .arg(screenshotId);
    }

    if (screenshotFileName != m_screenshotFileName) {
        m_screenshotFileName = screenshotFileName;

        QUrl screenshotUrl = QString("file://%1").arg(m_screenshotFileName);
        if (m_session) {
            m_session->setScreenshot(screenshotUrl);
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
    if (value != m_fullscreen) {
        m_fullscreen = value;
        Q_EMIT fullscreenChanged(value);
    }
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

void ApplicationInfo::onSessionSurfaceChanged(MirSurface* surface)
{
    if (surface != nullptr && m_state == Starting) {
        if (m_requestedState == RequestedRunning) {
            setState(Running);
        } else {
            setState(Suspended);
        }
    }
}
