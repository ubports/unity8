/*
 * Copyright (C) 2014-2016 Canonical, Ltd.
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

#include "SurfaceManager.h"

#include "ApplicationInfo.h"
#include "VirtualKeyboard.h"

#include <paths.h>

SurfaceManager *SurfaceManager::the_surface_manager = nullptr;

SurfaceManager *SurfaceManager::instance()
{
    return the_surface_manager;
}

SurfaceManager::SurfaceManager(QObject *parent) :
    QObject(parent)
    , m_virtualKeyboard(nullptr)
{
    Q_ASSERT(the_surface_manager == nullptr);
    the_surface_manager = this;

    m_virtualKeyboard = new VirtualKeyboard;
    connect(m_virtualKeyboard, &QObject::destroyed, this, [this](QObject *obj) {
        MirSurface* surface = qobject_cast<MirSurface*>(obj);
        m_virtualKeyboard = nullptr;
        Q_EMIT inputMethodSurfaceChanged();
        Q_EMIT surfaceDestroyed(surface);
    });
}

SurfaceManager::~SurfaceManager()
{
    Q_ASSERT(the_surface_manager == this);
    the_surface_manager = nullptr;
}

MirSurface *SurfaceManager::createSurface(const QString& name,
                                          Mir::Type type,
                                          Mir::State state,
                                          const QUrl& screenshot)
{
    MirSurface* surface = new MirSurface(name, type, state, screenshot);
    connect(surface, &QObject::destroyed, this, [this](QObject *obj) {
        MirSurface* surface = qobject_cast<MirSurface*>(obj);
        Q_EMIT surfaceDestroyed(surface);
    });

    surface->setMinimumWidth(m_newSurfaceMinimumWidth);
    surface->setMaximumWidth(m_newSurfaceMaximumWidth);
    surface->setMinimumHeight(m_newSurfaceMinimumHeight);
    surface->setMaximumHeight(m_newSurfaceMaximumHeight);
    surface->setWidthIncrement(m_newSurfaceWidthIncrement);
    surface->setHeightIncrement(m_newSurfaceHeightIncrement);

    Q_EMIT surfaceCreated(surface);
    return surface;
}

MirSurface *SurfaceManager::inputMethodSurface() const
{
    return m_virtualKeyboard;
}

void SurfaceManager::setNewSurfaceMinimumWidth(int value)
{
    if (m_newSurfaceMinimumWidth != value) {
        m_newSurfaceMinimumWidth = value;
        Q_EMIT newSurfaceMinimumWidthChanged(m_newSurfaceMinimumWidth);
    }
}

void SurfaceManager::setNewSurfaceMaximumWidth(int value)
{
    if (m_newSurfaceMaximumWidth != value) {
        m_newSurfaceMaximumWidth = value;
        Q_EMIT newSurfaceMaximumWidthChanged(m_newSurfaceMaximumWidth);
    }
}

void SurfaceManager::setNewSurfaceMinimumHeight(int value)
{
    if (m_newSurfaceMinimumHeight != value) {
        m_newSurfaceMinimumHeight = value;
        Q_EMIT newSurfaceMinimumHeightChanged(m_newSurfaceMinimumHeight);
    }
}

void SurfaceManager::setNewSurfaceMaximumHeight(int value)
{
    if (m_newSurfaceMaximumHeight != value) {
        m_newSurfaceMaximumHeight = value;
        Q_EMIT newSurfaceMaximumHeightChanged(m_newSurfaceMaximumHeight);
    }
}

void SurfaceManager::setNewSurfaceWidthIncrement(int value)
{
    if (m_newSurfaceWidthIncrement != value) {
        m_newSurfaceWidthIncrement = value;
        Q_EMIT newSurfaceWidthIncrementChanged(m_newSurfaceWidthIncrement);
    }
}

void SurfaceManager::setNewSurfaceHeightIncrement(int value)
{
    if (m_newSurfaceHeightIncrement != value) {
        m_newSurfaceHeightIncrement = value;
        Q_EMIT newSurfaceHeightIncrementChanged(m_newSurfaceHeightIncrement);
    }
}
