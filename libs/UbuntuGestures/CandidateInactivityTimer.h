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

#ifndef UBUNTUGESTURES_CANDIDATE_INACTIVITY_TIMER_H
#define UBUNTUGESTURES_CANDIDATE_INACTIVITY_TIMER_H

#include <QObject>

class QQuickItem;

#include "Timer.h"

namespace UbuntuGestures {

class UBUNTUGESTURES_EXPORT CandidateInactivityTimer : public QObject {
    Q_OBJECT
public:
    CandidateInactivityTimer(int touchId, QQuickItem *candidate,
                             AbstractTimerFactory &timerFactory,
                             QObject *parent = nullptr);

    const int durationMs = 350;

Q_SIGNALS:
    void candidateDefaulted(int touchId, QQuickItem *candidate);
private Q_SLOTS:
    void onTimeout();
private:
    AbstractTimer *m_timer;
    int m_touchId;
    QQuickItem *m_candidate;
};

} // namespace UbuntuGestures

#endif // UBUNTUGESTURES_CANDIDATE_INACTIVITY_TIMER_H
