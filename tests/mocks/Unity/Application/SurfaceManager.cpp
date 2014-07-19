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
#include "SurfaceManager.h"

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
{
}
