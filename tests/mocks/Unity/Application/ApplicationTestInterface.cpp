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
#include "SurfaceManager.h"
#include "MirSurfaceItem.h"
#include "MirSurfaceItemModel.h"

quint32 nextId = 0;

ApplicationTestInterface::ApplicationTestInterface(QObject* parent)
    : QDBusAbstractAdaptor(parent)
{
    QDBusConnection connection = QDBusConnection::sessionBus();
    connection.registerService("com.canonical.Unity8");
    connection.registerObject("/com/canonical/Unity8/Mocks", parent);
}

quint32 ApplicationTestInterface::addPromptSurface(const QString &appId, const QString &surfaceImage)
{
    qDebug() << "ApplicationTestInterface::addPromptSurface to " << appId;

    ApplicationInfo* application = ApplicationManager::singleton()->findApplication(appId);
    if (!application) {
        qDebug() << "ApplicationTestInterface::addPromptSurface - No application found for " << appId;
        return 0;
    }
    quint32 surfaceId = ++nextId;
    MirSurfaceItem* surface = SurfaceManager::singleton()->createSurface(
        QString("%1-Prompt%2").arg(appId)
                              .arg(surfaceId),
        MirSurfaceItem::Normal,
        MirSurfaceItem::Maximized,
        QUrl(surfaceImage));
    m_childItems[surfaceId] = surface;
    application->addPromptSurface(surface);

    return surfaceId;
}

quint32 ApplicationTestInterface::addChildSurface(const QString& appId, const quint32 existingSurfaceId, const QString& surfaceImage)
{
    qDebug() << "ApplicationTestInterface::addChildSurface to " << appId;

    ApplicationInfo* application = ApplicationManager::singleton()->findApplication(appId);
    if (!application) {
        qDebug() << "ApplicationTestInterface::addChildSurface - No application found for " << appId;
        return 0;
    }

    MirSurfaceItem* parentSurface = nullptr;
    if (m_childItems.contains(existingSurfaceId)) {
        parentSurface = m_childItems[existingSurfaceId];
    } else if (application->surface()) {
        parentSurface = application->surface();
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
    m_childItems[surfaceId] = surface;

    return surfaceId;
}

void ApplicationTestInterface::removeSurface(int surfaceId)
{
    qDebug() << "ApplicationTestInterface::removeSurface - " << surfaceId;

    if (!m_childItems.contains(surfaceId)) {
        qDebug() << "ApplicationTestInterface::removeSurface - No added surface for " << surfaceId;
        return;
    }
    MirSurfaceItem* surface = m_childItems.take(surfaceId);
    Q_EMIT surface->removed();
}
