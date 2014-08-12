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
#include "MirSurfaceItemModel.h"

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
    , m_promptSurfaces(new MirSurfaceItemModel(this))
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
    , m_promptSurfaces(new MirSurfaceItemModel(this))
{
    connect(this, &ApplicationInfo::stateChanged, this, &ApplicationInfo::onStateChanged);
}

ApplicationInfo::~ApplicationInfo()
{
    QList<MirSurfaceItem*> promptSurfaces(m_promptSurfaces->list());
    for (MirSurfaceItem* promptSurface : promptSurfaces) {
        delete promptSurface;
    }

    delete m_surface;
    delete m_promptSurfaces;
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

    setSurface(SurfaceManager::singleton()->createSurface(name(),
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
    }

    m_surface = surface;

    if (m_surface) {
        m_surface->setApplication(this);
        m_surface->setParent(this);
    }

    Q_EMIT surfaceChanged(m_surface);
}

void ApplicationInfo::addPromptSurface(MirSurfaceItem* surface)
{
    insertPromptSurface(m_promptSurfaces->count(), surface);
}

void ApplicationInfo::insertPromptSurface(uint index, MirSurfaceItem* surface)
{
    qDebug() << "ApplicationInfo::insertPromptSurface - " << surface->name() << " to " << name() << " @  " << index;

    surface->setApplication(this);
    m_promptSurfaces->insertSurface(index, surface);
}

void ApplicationInfo::removeSurface(MirSurfaceItem* surface)
{
    qDebug() << "Application::removeSurface - " << surface->name() << " from " << name();

    if (m_surface == surface) {
        setSurface(nullptr);
    } else {
        m_promptSurfaces->removeSurface(surface);
        surface->setApplication(nullptr);
    }
}

MirSurfaceItemModel* ApplicationInfo::promptSurfaces() const
{
    return m_promptSurfaces;
}
