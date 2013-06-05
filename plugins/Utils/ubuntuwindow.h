/*
 * Copyright (C) 2012 Canonical, Ltd.
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

#ifndef UBUNTUWINDOW_H
#define UBUNTUWINDOW_H

#include <QtCore/QObject>
#include <QtQuick/QQuickWindow>

class UbuntuWindow : public QObject
{
    Q_OBJECT

    Q_PROPERTY(int ubuntuSurfaceRole READ ubuntuSurfaceRole WRITE setUbuntuSurfaceRole NOTIFY ubuntuSurfaceRoleChanged)

public:
    explicit UbuntuWindow(QObject *parent = 0);

    int ubuntuSurfaceRole() const;
    void setUbuntuSurfaceRole(int ubuntuSurfaceRole);

Q_SIGNALS:
    void ubuntuSurfaceRoleChanged(int);

private:
    QQuickWindow* m_window;
};

#endif // UBUNTUWINDOW_H
