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

#ifndef SURFACEMANAGER_H
#define SURFACEMANAGER_H

#include <QObject>

class MirSurfaceItem;

class SurfaceManager : public QObject
{
    Q_OBJECT
public:
    explicit SurfaceManager(QObject *parent = 0);

    static SurfaceManager *singleton();

Q_SIGNALS:
    void countChanged();
    void surfaceCreated(MirSurfaceItem *surface);
    void surfaceDestroyed(MirSurfaceItem *surface);

private:
    static SurfaceManager *the_surface_manager;

};

#endif // SURFACEMANAGER_H
