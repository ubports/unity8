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

    Q_PROPERTY(int newSurfaceMinimumWidth READ newSurfaceMinimumWidth WRITE setNewSurfaceMinimumWidth NOTIFY newSurfaceMinimumWidthChanged)
    Q_PROPERTY(int newSurfaceMaximumWidth READ newSurfaceMaximumWidth WRITE setNewSurfaceMaximumWidth NOTIFY newSurfaceMaximumWidthChanged)
    Q_PROPERTY(int newSurfaceMinimumHeight READ newSurfaceMinimumHeight WRITE setNewSurfaceMinimumHeight NOTIFY newSurfaceMinimumHeightChanged)
    Q_PROPERTY(int newSurfaceMaximumHeight READ newSurfaceMaximumHeight WRITE setNewSurfaceMaximumHeight NOTIFY newSurfaceMaximumHeightChanged)
    Q_PROPERTY(int newSurfaceWidthIncrement READ newSurfaceWidthIncrement WRITE setNewSurfaceWidthIncrement NOTIFY newSurfaceWidthIncrementChanged)
    Q_PROPERTY(int newSurfaceHeightIncrement READ newSurfaceHeightIncrement WRITE setNewSurfaceHeightIncrement NOTIFY newSurfaceHeightIncrementChanged)

public:
    explicit SurfaceManager(QObject *parent = 0);

    static SurfaceManager *singleton();

    Q_INVOKABLE MirSurface* createSurface(const QString& name,
                                  Mir::Type type,
                                  Mir::State state,
                                  const QUrl& screenshot);

    // To be used in the tests
    Q_INVOKABLE MirSurface* inputMethodSurface();

    int newSurfaceMinimumWidth() const { return m_newSurfaceMinimumWidth; }
    void setNewSurfaceMinimumWidth(int value);

    int newSurfaceMaximumWidth() const { return m_newSurfaceMaximumWidth; }
    void setNewSurfaceMaximumWidth(int value);

    int newSurfaceMinimumHeight() const { return m_newSurfaceMinimumHeight; }
    void setNewSurfaceMinimumHeight(int value);

    int newSurfaceMaximumHeight() const { return m_newSurfaceMaximumHeight; }
    void setNewSurfaceMaximumHeight(int value);

    int newSurfaceWidthIncrement() const { return m_newSurfaceWidthIncrement; }
    void setNewSurfaceWidthIncrement(int);

    int newSurfaceHeightIncrement() const { return m_newSurfaceHeightIncrement; }
    void setNewSurfaceHeightIncrement(int);

Q_SIGNALS:
    void countChanged();
    void surfaceCreated(MirSurface *surface);
    void surfaceDestroyed(MirSurface*surface);

    void newSurfaceMinimumWidthChanged(int value);
    void newSurfaceMaximumWidthChanged(int value);
    void newSurfaceMinimumHeightChanged(int value);
    void newSurfaceMaximumHeightChanged(int value);
    void newSurfaceWidthIncrementChanged(int value);
    void newSurfaceHeightIncrementChanged(int value);

private:
    static SurfaceManager *the_surface_manager;
    VirtualKeyboard *m_virtualKeyboard;

    int m_newSurfaceMinimumWidth{0};
    int m_newSurfaceMaximumWidth{0};
    int m_newSurfaceMinimumHeight{0};
    int m_newSurfaceMaximumHeight{0};
    int m_newSurfaceWidthIncrement{1};
    int m_newSurfaceHeightIncrement{1};
};

#endif // SURFACEMANAGER_H
