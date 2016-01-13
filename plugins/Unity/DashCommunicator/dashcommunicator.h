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

// Qt
#include <QThread>
#include <QMutex>

class DashConnection;

class DashCommunicator: public QThread
{
    Q_OBJECT
public:
    explicit DashCommunicator(QObject *parent = 0);
    ~DashCommunicator();

public Q_SLOTS:
    void setCurrentScope(int index, bool animate, bool isSwipe);

protected:
    void run() override;

private:
    DashConnection *m_dashConnection;
    bool m_created;
    QMutex m_mutex;
};

#endif
