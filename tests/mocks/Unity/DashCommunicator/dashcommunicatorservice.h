/*
 * Copyright (C) 2014, 2015 Canonical, Ltd.
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

#ifndef DASHCOMMUNICATORSERVICE_H
#define DASHCOMMUNICATORSERVICE_H

#include <QObject>

class DashCommunicatorService: public QObject
{
    Q_OBJECT
public:
    DashCommunicatorService(QObject *parent = 0);
    ~DashCommunicatorService();

    static DashCommunicatorService *theCommunicatorService();

Q_SIGNALS:
    void setCurrentScopeRequested(int index, bool animate, bool isSwipe);

public Q_SLOTS:
    void mockSetCurrentScope(int index, bool animate, bool isSwipe);

private:
    static DashCommunicatorService *m_theCommunicatorService;
};

#endif // DBUSUNITYSESSIONSERVICE_H
