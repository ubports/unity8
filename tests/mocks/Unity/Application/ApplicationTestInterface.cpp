/*
 * Copyright (C) 2014,2015 Canonical, Ltd.
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
#include "ApplicationTestInterface.h"
#include "ApplicationManager.h"
#include "SessionManager.h"
#include "SurfaceManager.h"
#include "Session.h"
#include "MirSurface.h"

#include <paths.h>

#include <QtDBus/QtDBus>

quint32 nextId = 0;

ApplicationTestInterface::ApplicationTestInterface(QObject* parent)
    : QDBusAbstractAdaptor(parent)
{
    QDBusConnection connection = QDBusConnection::sessionBus();
    connection.registerService("com.canonical.Unity8");
    connection.registerObject("/com/canonical/Unity8/Mocks", parent);
}

Session* ApplicationTestInterface::addChildSession(Session* existingSession, const QString& surfaceImage)
{
    if (!existingSession) return nullptr;

    QUrl screenshotUrl = QString("file://%1/Dash/graphics/phone/screenshots/%2@12.png")
            .arg(qmlDirectory())
            .arg(surfaceImage);

    Session* session = SessionManager::singleton()->createSession(
        QString("%1-Child%2").arg(existingSession->name())
                             .arg(existingSession->childSessions()->count()),
        screenshotUrl);
    existingSession->addChildSession(session);
    session->createSurface();

    return session;
}

void ApplicationTestInterface::removeSession(Session* existingSession)
{
    qDebug() << "ApplicationTestInterface::removeSession - " << existingSession;

    if (existingSession)
        existingSession->setLive(false);
}

void ApplicationTestInterface::removeSurface(MirSurface* existingSurface)
{
    qDebug() << "ApplicationTestInterface::removeSurface - " << existingSurface;

    if (existingSurface)
        existingSurface->setLive(false);
}

quint32 ApplicationTestInterface::addChildSession(const QString& appId, quint32 existingSessionId, const QString& surfaceImage)
{
    qDebug() << "ApplicationTestInterface::addChildSession to " << appId;

    ApplicationInfo* application = ApplicationManager::singleton()->findApplication(appId);
    if (!application) {
        qDebug() << "ApplicationTestInterface::addChildSession - No application found for " << appId;
        return 0;
    }

    Session* parentSession = nullptr;
    if (m_childSessions.contains(existingSessionId)) {
        parentSession = m_childSessions[existingSessionId];
    } else if (application->session()) {
        parentSession = application->session();
    } else {
        qDebug() << "ApplicationTestInterface::addChildSession - No session for " << appId << ":" << existingSessionId;
        return 0;
    }

    QUrl screenshotUrl = QString("file://%1/Dash/graphics/phone/screenshots/%2@12.png")
            .arg(qmlDirectory())
            .arg(surfaceImage);

    quint32 sessionId = ++nextId;
    Session* session = SessionManager::singleton()->createSession(
        QString("%1-Child%2").arg(parentSession->name())
                             .arg(parentSession->childSessions()->count()),
        screenshotUrl);
    parentSession->addChildSession(session);
    session->createSurface();
    m_childSessions[sessionId] = session;

    return sessionId;
}

void ApplicationTestInterface::removeSession(quint32 sessionId)
{
    if (!m_childSessions.contains(sessionId)) {
        qDebug() << "ApplicationTestInterface::removeSession - No added session for " << sessionId;
        return;
    }
    Session* session = m_childSessions.take(sessionId);
    removeSession(session);
}
