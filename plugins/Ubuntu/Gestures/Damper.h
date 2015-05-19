/*
 * Copyright (C) 2013 Canonical, Ltd.
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

#ifndef UBUNTU_GESTURES_DAMPER_H
#define UBUNTU_GESTURES_DAMPER_H

#include <QtCore/QPointF>

/*
  Decreases the oscillations of a value along an axis.
 */
template <class Type> class Damper {
public:
    Damper() : m_value(0), m_maxDelta(0) { }

    // Maximum delta between the raw value and its dampened counterpart.
    void setMaxDelta(Type maxDelta) {
        if (maxDelta < 0) qFatal("Damper::maxDelta must be a positive number.");
        m_maxDelta = maxDelta;
    }
    Type maxDelta() const { return m_maxDelta; }

    void reset(Type value) {
        m_value = value;
    }

    Type update(Type value) {
        Type delta = value - m_value;
        if (delta > 0 && delta > m_maxDelta) {
            m_value += delta - m_maxDelta;
        } else if (delta < 0 && delta < -m_maxDelta) {
            m_value += delta + m_maxDelta;
        }

        return m_value;
    }

    Type value() const { return m_value; }

private:
    Type m_value;
    Type m_maxDelta;
};

/*
    A point that has its movement dampened.
 */
class DampedPointF {
public:
    void setMaxDelta(qreal maxDelta) {
        m_x.setMaxDelta(maxDelta);
        m_y.setMaxDelta(maxDelta);
    }

    qreal maxDelta() const { return m_x.maxDelta(); }

    void reset(const QPointF &point) {
        m_x.reset(point.x());
        m_y.reset(point.y());
    }

    void update(const QPointF &point) {
        m_x.update(point.x());
        m_y.update(point.y());
    }

    qreal x() const { return m_x.value(); }
    qreal y() const { return m_y.value(); }
private:
    Damper<qreal> m_x;
    Damper<qreal> m_y;
};

QDebug operator<<(QDebug dbg, const DampedPointF &p);

#endif // UBUNTU_GESTURES_DAMPER_H
