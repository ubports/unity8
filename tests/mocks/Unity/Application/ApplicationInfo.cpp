/*
 * Copyright (C) 2013-2014 Canonical, Ltd.
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
#include "MirSessionItem.h"
#include "SessionManager.h"

#include <QGuiApplication>
#include <QQuickItem>
#include <QQuickView>
#include <QQmlComponent>

ApplicationInfo::ApplicationInfo(const QString &appId, QObject *parent)
    : ApplicationInfoInterface(appId, parent)
    , m_appId(appId)
    , m_stage(MainStage)
    , m_state(Starting)
    , m_focused(false)
    , m_fullscreen(false)
    , m_parentItem(0)
    , m_session(0)
{
    createSession();
}

ApplicationInfo::ApplicationInfo(QObject *parent)
    : ApplicationInfoInterface(QString(), parent)
    , m_stage(MainStage)
    , m_state(Starting)
    , m_focused(false)
    , m_fullscreen(false)
    , m_parentItem(0)
    , m_session(0)
{
    createSession();
}

ApplicationInfo::~ApplicationInfo()
{
    delete m_session;
}

void ApplicationInfo::createSession()
{
    setSession(SessionManager::singleton()->createSession(appId(), screenshot()));
}

void ApplicationInfo::setSession(MirSessionItem* session)
{
    qDebug() << "Application::setSession - appId=" << appId() << "session=" << session;
    if (m_session == session)
        return;

    if (m_session) {
        disconnect(this, 0, m_session, 0);
        m_session->setApplication(nullptr);
        m_session->setParent(nullptr);
    }

    m_session = session;

    if (m_session) {
        m_session->setApplication(this);
        m_session->setParent(this);
        connect(this, &ApplicationInfo::screenshotChanged, m_session, [this](const QUrl& screenshot) {
            m_session->setScreenshot(screenshot);
        });
    }

    Q_EMIT sessionChanged(m_session);
}
