/*
 * Copyright (C) 2014-2015 Canonical, Ltd.
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

#include "VirtualKeyboard.h"

#include <paths.h>

SurfaceManager *SurfaceManager::the_surface_manager = nullptr;

SurfaceManager *SurfaceManager::singleton()
{
    if (!the_surface_manager) {
        the_surface_manager = new SurfaceManager();
    }
    return the_surface_manager;
}

SurfaceManager::SurfaceManager(QObject *parent) :
    QObject(parent)
    , m_virtualKeyboard(nullptr)
{
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
    Q_EMIT surfaceCreated(surface);
    return surface;
}

MirSurface *SurfaceManager::inputMethodSurface()
{
    if (!m_virtualKeyboard) {
        m_virtualKeyboard = new VirtualKeyboard;
        connect(m_virtualKeyboard, &QObject::destroyed, this, [this](QObject *obj) {
            MirSurface* surface = qobject_cast<MirSurface*>(obj);
            Q_EMIT surfaceDestroyed(surface);
        });
        Q_EMIT surfaceCreated(m_virtualKeyboard);
    }
    return m_virtualKeyboard;
}
