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

#include "CandidateInactivityTimer.h"

namespace UbuntuGestures {

CandidateInactivityTimer::CandidateInactivityTimer(int touchId, QQuickItem *candidate,
        AbstractTimerFactory &timerFactory, QObject *parent)
    : QObject(parent)
    , m_touchId(touchId)
    , m_candidate(candidate)
{
    m_timer = timerFactory.createTimer(this);
    connect(m_timer, &AbstractTimer::timeout,
            this, &CandidateInactivityTimer::onTimeout);
    m_timer->setInterval(durationMs);
    m_timer->setSingleShot(true);
    m_timer->start();
}

void CandidateInactivityTimer::onTimeout()
{
    qWarning("[TouchRegistry] Candidate for touch %d defaulted!", m_touchId);
    Q_EMIT candidateDefaulted(m_touchId, m_candidate);
}

} // namespace UbuntuGestures
