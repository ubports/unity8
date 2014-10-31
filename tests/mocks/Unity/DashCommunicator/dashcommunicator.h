/*
 * Copyright (C) 2014 Canonical, Ltd.
 *
 * This program is free software: you can redistribute it and/or modify it under
 * the terms of the GNU Lesser General Public License version 3, as published by
 * the Free Software Foundation.
 *
 * This program is distributed in the hope that it will be useful, but WITHOUT
 * ANY WARRANTY; without even the implied warranties of MERCHANTABILITY,
 * SATISFACTORY QUALITY, or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
 * Lesser General Public License for more details.
 *
 * You should have received a copy of the GNU Lesser General Public License
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.
 */

#ifndef DASHCOMMUNICATOR_H
#define DASHCOMMUNICATOR_H

#include <QObject>

class DashCommunicator: public QObject
{
    Q_OBJECT
    Q_CLASSINFO("D-Bus Interface", "com.canonical.Unity.DashCommunicator")

public:
    DashCommunicator(QObject *parent = 0);
    ~DashCommunicator();

public Q_SLOTS:
    void setCurrentScope(int index, bool animate, bool reset);

Q_SIGNALS:
    // This mock just emits calls back to the QML api for the plugin to verify calls
    void setCurrentScopeCalled(int index, bool animate, bool reset);
};

#endif
