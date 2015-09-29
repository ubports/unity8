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

#include "dashcommunicator.h"
#include "dashconnection.h"

#include <QObject>

DashCommunicator::DashCommunicator(QObject *parent):
    QThread(parent),
    m_dashConnection(nullptr),
    m_created(false)
{
    start();
}

void DashCommunicator::setCurrentScope(int index, bool animate, bool isSwipe)
{
    m_mutex.lock();
    if (m_created) {
        QMetaObject::invokeMethod(m_dashConnection, "setCurrentScope",
                                  Q_ARG(int, index),
                                  Q_ARG(bool, animate),
                                  Q_ARG(bool, isSwipe));
    }
    m_mutex.unlock();
}

void DashCommunicator::run()
{
    m_dashConnection = new DashConnection(QStringLiteral("com.canonical.UnityDash"),
                                 QStringLiteral("/com/canonical/UnityDash"),
                                 QLatin1String(""), this);
    m_mutex.lock();
    m_created = true;
    m_mutex.unlock();

    exec();
}
