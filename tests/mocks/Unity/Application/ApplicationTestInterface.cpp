/*
 * Copyright (C) 2014 Canonical, Ltd.
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
#include "MirSessionItem.h"
#include "MirSurfaceItem.h"

quint32 nextId = 0;

ApplicationTestInterface::ApplicationTestInterface(QObject* parent)
    : QDBusAbstractAdaptor(parent)
{
    QDBusConnection connection = QDBusConnection::sessionBus();
    connection.registerService("com.canonical.Unity8");
    connection.registerObject("/com/canonical/Unity8/Mocks", parent);
}

quint32 ApplicationTestInterface::addChildSession(const QString& appId, quint32 existingSessionId, const QString& surfaceImage)
{
    qDebug() << "ApplicationTestInterface::addChildSession to " << appId;

    ApplicationInfo* application = ApplicationManager::singleton()->findApplication(appId);
    if (!application) {
        qDebug() << "ApplicationTestInterface::addChildSession - No application found for " << appId;
        return 0;
    }

    MirSessionItem* parentSession = nullptr;
    if (m_childSessions.contains(existingSessionId)) {
        parentSession = m_childSessions[existingSessionId];
    } else if (application->session()) {
        parentSession = application->session();
    } else {
        qDebug() << "ApplicationTestInterface::addChildSession - No session for " << appId << ":" << existingSessionId;
        return 0;
    }

    quint32 sessionId = ++nextId;
    MirSessionItem* session = SessionManager::singleton()->createSession(
        QString("%1-Child%2").arg(parentSession->name())
                             .arg(sessionId),
        QUrl(surfaceImage));
    parentSession->addChildSession(session);
    session->createSurface();
    m_childSessions[sessionId] = session;

    return sessionId;
}

void ApplicationTestInterface::removeSession(quint32 sessionId)
{
    qDebug() << "ApplicationTestInterface::removeSession - " << sessionId;

    if (!m_childSessions.contains(sessionId)) {
        qDebug() << "ApplicationTestInterface::removeSession - No added session for " << sessionId;
        return;
    }
    MirSessionItem* session = m_childSessions.take(sessionId);
    Q_EMIT session->removed();
}

quint32 ApplicationTestInterface::addChildSurface(const QString& appId, quint32 existingSessionId, quint32 existingSurfaceId, const QString& surfaceImage)
{
    qDebug() << "ApplicationTestInterface::addChildSurface to " << appId;

    ApplicationInfo* application = ApplicationManager::singleton()->findApplication(appId);
    if (!application) {
        qDebug() << "ApplicationTestInterface::addChildSurface - No application found for " << appId;
        return 0;
    }

    MirSurfaceItem* parentSurface = nullptr;
    if (m_childSessions.contains(existingSessionId) && m_childSessions[existingSessionId]->surface()) {
        parentSurface = m_childSessions[existingSessionId]->surface();
    } else if (m_childSurfaces.contains(existingSurfaceId)) {
        parentSurface = m_childSurfaces[existingSurfaceId];
    } else if (application->session() && application->session()->surface()) {
        parentSurface = application->session()->surface();
    } else {
        qDebug() << "ApplicationTestInterface::addChildSurface - No surface for " << appId << ":" << existingSurfaceId;
        return 0;
    }

    quint32 surfaceId = ++nextId;
    MirSurfaceItem* surface = SurfaceManager::singleton()->createSurface(
        QString("%1-Child%2").arg(parentSurface->name())
                             .arg(surfaceId),
        MirSurfaceItem::Normal,
        MirSurfaceItem::Maximized,
        QUrl(surfaceImage));
    parentSurface->addChildSurface(surface);
    m_childSurfaces[surfaceId] = surface;

    return surfaceId;
}

void ApplicationTestInterface::removeSurface(quint32 surfaceId)
{
    qDebug() << "ApplicationTestInterface::removeSurface - " << surfaceId;

    if (!m_childSurfaces.contains(surfaceId)) {
        qDebug() << "ApplicationTestInterface::removeSurface - No added surface for " << surfaceId;
        return;
    }
    MirSurfaceItem* surface = m_childSurfaces.take(surfaceId);
    Q_EMIT surface->removed();
}
