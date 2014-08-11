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
#include "ApplicationDBusAdaptor.h"
#include "ApplicationManager.h"
#include "SurfaceManager.h"
#include "MirSurfaceItem.h"

quint32 nextId = 0;

ApplicationDBusAdaptor::ApplicationDBusAdaptor(ApplicationManager* applicationManager)
    : QDBusAbstractAdaptor(applicationManager)
    , m_applicationManager(applicationManager)
{
}

MirSurfaceItem* topSurface(MirSurfaceItem* surface)
{
    if (!surface)
        return nullptr;

    MirSurfaceItem* child = NULL;
    Q_FOREACH (MirSurfaceItem *childSurface, surface->childSurfaceList()) {
        child = topSurface(childSurface);
        if (child) {
            break;
        }
    }
    return child ? child : surface;
}

quint32 ApplicationDBusAdaptor::addPromptSurface(const QString &appId, const QString &surfaceImage)
{
    qDebug() << "ApplicationDBusAdaptor::addPromptSurface to " << appId;

    ApplicationInfo* application = m_applicationManager->findApplication(appId);
    if (!application) {
        qDebug() << "ApplicationDBusAdaptor::addChildSurface - No application found for " << appId;
        return 0;
    }
    quint32 surfaceId = ++nextId;
    MirSurfaceItem* surface = new MirSurfaceItem(QString("%1-ChildSurface%2").arg(appId).arg(surfaceId),
                                                 MirSurfaceItem::Normal,
                                                 MirSurfaceItem::Maximized,
                                                 QUrl(surfaceImage));
    m_childItems[surfaceId] = surface;

    if (application->promptSurfaceList().count() > 0) {
        surface->setParentSurface(topSurface(application->promptSurfaceList()[0]));
    } else {
        application->addPromptSurface(surface);
    }

    return surfaceId;
}

void ApplicationDBusAdaptor::removeChildSurface(int surfaceId)
{
    qDebug() << "ApplicationDBusAdaptor::removeChildSurface - " << surfaceId;

    if (!m_childItems.contains(surfaceId)) {
        qDebug() << "ApplicationDBusAdaptor::removeChildSurface - No added surface for " << surfaceId;
        return;
    }
    MirSurfaceItem* surface = m_childItems.take(surfaceId);
    Q_EMIT surface->removed();
}
