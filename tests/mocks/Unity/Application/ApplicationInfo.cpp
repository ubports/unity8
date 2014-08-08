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
#include "MirSurfaceItem.h"
#include "SurfaceManager.h"

#include <QGuiApplication>
#include <QQuickItem>
#include <QQuickView>
#include <QQmlComponent>
#include <QTimer>

ApplicationInfo::ApplicationInfo(const QString &appId, QObject *parent)
    : ApplicationInfoInterface(appId, parent)
    , m_appId(appId)
    , m_stage(MainStage)
    , m_state(Starting)
    , m_focused(false)
    , m_fullscreen(false)
    , m_parentItem(0)
    , m_surface(0)
{
    connect(this, &ApplicationInfo::stateChanged, this, &ApplicationInfo::onStateChanged);
}

ApplicationInfo::ApplicationInfo(QObject *parent)
    : ApplicationInfoInterface(QString(), parent)
    , m_stage(MainStage)
    , m_state(Starting)
    , m_focused(false)
    , m_fullscreen(false)
    , m_parentItem(0)
    , m_surface(0)
{
    connect(this, &ApplicationInfo::stateChanged, this, &ApplicationInfo::onStateChanged);
}

ApplicationInfo::~ApplicationInfo()
{
    if (m_surface) {
        Q_EMIT SurfaceManager::singleton()->surfaceDestroyed(m_surface);
        m_surface->deleteLater();
    }
}

void ApplicationInfo::onStateChanged(State state)
{
    if (state == ApplicationInfo::Running) {
        QTimer::singleShot(1000, this, SLOT(createSurface()));
    } else if (state == ApplicationInfo::Stopped) {
        setSurface(nullptr);
    }
}

void ApplicationInfo::createSurface()
{
    if (m_surface || state() == ApplicationInfo::Stopped) return;

    setSurface(new MirSurfaceItem(name(),
                                   MirSurfaceItem::Normal,
                                   fullscreen() ? MirSurfaceItem::Fullscreen : MirSurfaceItem::Maximized,
                                   screenshot()));
}

void ApplicationInfo::setSurface(MirSurfaceItem* surface)
{
    qDebug() << "Application::setSurface - appId=" << appId() << "surface=" << surface;
    if (m_surface == surface)
        return;

    if (m_surface) {
        m_surface->setApplication(nullptr);
        m_surface->setParent(nullptr);
        SurfaceManager::singleton()->unregisterSurface(m_surface);
    }

    m_surface = surface;

    if (m_surface) {
        m_surface->setApplication(this);
        m_surface->setParent(this);
        SurfaceManager::singleton()->registerSurface(m_surface);
    }

    Q_EMIT surfaceChanged(m_surface);
    SurfaceManager::singleton()->registerSurface(m_surface);
}

void ApplicationInfo::addPromptSurface(MirSurfaceItem* surface)
{
    qDebug() << "ApplicationInfo::addPromptSurface " << surface->name() << " to " << name();
    if (surface == m_surface || m_promptSurfaces.contains(surface)) return;

    surface->setApplication(this);
    m_promptSurfaces.append(surface);
    Q_EMIT promptSurfacesChanged();
}

void ApplicationInfo::removeSurface(MirSurfaceItem* surface)
{
    if (m_surface == surface) {
        setSurface(nullptr);
    } else if (m_promptSurfaces.contains(surface)) {
        qDebug() << "Application::removeSurface " << surface->name() << " from " << name();

        m_promptSurfaces.removeAll(surface);
        surface->setApplication(nullptr);

        Q_EMIT promptSurfacesChanged();
    }
}

QList<MirSurfaceItem*> ApplicationInfo::promptSurfaceList() const
{
    return m_promptSurfaces;
}

QQmlListProperty<MirSurfaceItem> ApplicationInfo::promptSurfaces()
{
    return QQmlListProperty<MirSurfaceItem>(this,
                                            0,
                                            ApplicationInfo::promptSurfaceCount,
                                            ApplicationInfo::promptSurfaceAt);
}

int ApplicationInfo::promptSurfaceCount(QQmlListProperty<MirSurfaceItem> *prop)
{
    ApplicationInfo *p = qobject_cast<ApplicationInfo*>(prop->object);
    return p->m_promptSurfaces.count();
}

MirSurfaceItem* ApplicationInfo::promptSurfaceAt(QQmlListProperty<MirSurfaceItem> *prop, int index)
{
    ApplicationInfo *p = qobject_cast<ApplicationInfo*>(prop->object);

    if (index < 0 || index >= p->m_promptSurfaces.count())
        return nullptr;
    return p->m_promptSurfaces[index];
}
