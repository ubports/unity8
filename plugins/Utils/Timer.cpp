/*
 * Copyright (C) 2015 Canonical, Ltd.
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

#include "Timer.h"

namespace UnityUtil {

Timer::Timer(QObject *parent) : AbstractTimer(parent)
{
    m_timer.setSingleShot(true);
    connect(&m_timer, &QTimer::timeout, this, &AbstractTimer::timeout);
}

int Timer::interval() const
{
    return m_timer.interval();
}

void Timer::setInterval(int msecs)
{
    m_timer.setInterval(msecs);
}

void Timer::start()
{
    m_timer.start();
}

void Timer::stop()
{
    m_timer.stop();
}

bool Timer::isRunning() const
{
    return m_timer.isActive();
}

bool Timer::isSingleShot() const
{
    return m_timer.isSingleShot();
}

void Timer::setSingleShot(bool value)
{
    m_timer.setSingleShot(value);
}

} // namespace UnityUtil
