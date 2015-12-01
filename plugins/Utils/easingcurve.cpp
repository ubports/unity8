/*
 * Copyright 2014 Canonical Ltd.
 *
 * This program is free software; you can redistribute it and/or modify
 * it under the terms of the GNU Lesser General Public License as published by
 * the Free Software Foundation; version 3.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
 * GNU Lesser General Public License for more details.
 *
 * You should have received a copy of the GNU Lesser General Public License
 * along with this program. If not, see <http://www.gnu.org/licenses/>.
 *
 * Authors: Michael Zanetti <michael.zanetti@canonical.com>
*/

#include "easingcurve.h"


EasingCurve::EasingCurve(QObject *parent):
    QObject(parent),
    m_progress(0),
    m_value(0)
{

}

QEasingCurve::Type EasingCurve::type() const
{
    return m_easingCurve.type();
}

void EasingCurve::setType(const QEasingCurve::Type type)
{
    // FIXME: Working around bug https://bugreports.qt-project.org/browse/QTBUG-38686 here
    QEasingCurve newCurve;
    newCurve.setType(type);
    newCurve.setPeriod(m_easingCurve.period());
    m_easingCurve = newCurve;
    Q_EMIT typeChanged();
}

qreal EasingCurve::period() const
{
    return m_easingCurve.period();
}

void EasingCurve::setPeriod(qreal period)
{
    m_easingCurve.setPeriod(period);
    Q_EMIT periodChanged();
}

qreal EasingCurve::progress() const
{
    return m_progress;
}

void EasingCurve::setProgress(qreal progress)
{
    if (m_progress != progress) {
        m_progress = progress;
        m_value = m_easingCurve.valueForProgress(m_progress);
        Q_EMIT progressChanged();
    }
}

qreal EasingCurve::value() const
{
    return m_value;
}
