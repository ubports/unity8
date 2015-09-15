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

#ifndef SURFACEMANAGER_H
#define SURFACEMANAGER_H

#include <QObject>

#include "MirSurface.h"
#include "VirtualKeyboard.h"

class SurfaceManager : public QObject
{
    Q_OBJECT
public:
    explicit SurfaceManager(QObject *parent = 0);

    static SurfaceManager *singleton();

    Q_INVOKABLE MirSurface* createSurface(const QString& name,
                                  Mir::Type type,
                                  Mir::State state,
                                  const QUrl& screenshot);

    // To be used in the tests
    Q_INVOKABLE MirSurface* inputMethodSurface();

Q_SIGNALS:
    void countChanged();
    void surfaceCreated(MirSurface *surface);
    void surfaceDestroyed(MirSurface*surface);

private:
    static SurfaceManager *the_surface_manager;
    VirtualKeyboard *m_virtualKeyboard;
};

#endif // SURFACEMANAGER_H
