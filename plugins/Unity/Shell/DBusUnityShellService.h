/*
 * Copyright (C) 2014 Canonical, Ltd.
 *
 * This program is free software: you can redistribute it and/or modify it under
 * the terms of the GNU Lesser General Public License version 3, as published by
 * the Free Software Foundation.
 *
 * This program is distributed in the hope that it will be useful, but WITHOUT
 * ANY WARRANTY; without even the implied warranties of MERCHANTABILITY,
 * SATISFACTORY QUALITY, or FITNESS FOR A PARTICULAR PURPOSE. See the GNU
 * Lesser General Public License for more details.
 *
 * You should have received a copy of the GNU Lesser General Public License
 * along with this program. If not, see <http://www.gnu.org/licenses/>.
 */

#ifndef DBUSUNITYSHELLSERVICE_H
#define DBUSUNITYSHELLSERVICE_H

#include <QObject>

class DBusUnityShellService : public QObject
{
    Q_OBJECT
    Q_CLASSINFO("D-Bus Interface", "com.canonical.Unity.Shell")
    Q_PROPERTY(int rotationAngle READ GetRotationAngle WRITE setRotationAngle NOTIFY RotationAngleChanged)

public:
    DBusUnityShellService();
    ~DBusUnityShellService();

    void setRotationAngle(int angle);

Q_SIGNALS:
    Q_SCRIPTABLE void RotationAngleChanged(int angle);

public Q_SLOTS:
    Q_SCRIPTABLE int GetRotationAngle();

private:
    int m_rotationAngle;
};

#endif // DBUSUNITYSHELLSERVICE_H
