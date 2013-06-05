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

#include "DirectionalDragArea.h"

#include <QtCore/qmath.h>

DirectionalDragArea::DirectionalDragArea(QQuickItem *parent)
    : QQuickItem(parent)
    , m_status(WaitingForTouch)
    , m_touchId(-1)
    , m_direction(DirectionalDragArea::Rightwards)
    , m_wideningAngle(0)
    , m_wideningFactor(0)
    , m_distanceThreshold(0)
{
}

DirectionalDragArea::Direction DirectionalDragArea::direction() const
{
    return m_direction;
}

void DirectionalDragArea::setDirection(DirectionalDragArea::Direction direction)
{
    if (direction != m_direction) {
        m_direction = direction;
        Q_EMIT directionChanged(m_direction);
    }
}

void DirectionalDragArea::setMaxDeviation(qreal value)
{
    if (m_dampedPos.maxDelta() != value) {
        m_dampedPos.setMaxDelta(value);
        Q_EMIT maxDeviationChanged(value);
    }
}

qreal DirectionalDragArea::wideningAngle() const
{
    return m_wideningAngle;
}

void DirectionalDragArea::setWideningAngle(qreal angle)
{
    if (angle == m_wideningAngle)
        return;

    m_wideningAngle = angle;
    m_wideningFactor = qTan(angle * M_PI / 180.0);
    Q_EMIT wideningAngleChanged(angle);
}

void DirectionalDragArea::setDistanceThreshold(qreal value)
{
    if (m_distanceThreshold != value) {
        m_distanceThreshold = value;
        Q_EMIT distanceThresholdChanged(value);
    }
}

qreal DirectionalDragArea::distance() const
{
    if (directionIsHorizontal()) {
        return m_previousPos.x() - m_startPos.x();
    } else {
        return m_previousPos.y() - m_startPos.y();
    }
}

qreal DirectionalDragArea::touchX() const
{
    return m_previousPos.x();
}

qreal DirectionalDragArea::touchY() const
{
    return m_previousPos.y();
}

void DirectionalDragArea::touchEvent(QTouchEvent *event)
{
    if (!isEnabled() || !isVisible()) {
        QQuickItem::touchEvent(event);
        return;
    }

    switch (m_status) {
        case WaitingForTouch:
            touchEvent_absent(event);
            break;
        case Undecided:
            touchEvent_undecided(event);
            break;
        case Recognized:
            touchEvent_recognized(event);
            break;
        default: // Rejected
            touchEvent_rejected(event);
            break;
    }
}

void DirectionalDragArea::touchEvent_absent(QTouchEvent *event)
{
    if ((event->touchPointStates() && (Qt::TouchPointPressed || Qt::TouchPointMoved))
            && event->touchPoints().count() == 1) {
        m_startPos = event->touchPoints()[0].pos();
        m_touchId = event->touchPoints()[0].id();
        m_dampedPos.reset(m_startPos);
        setPreviousPos(m_startPos);
        setStatus(Undecided);
    }
}

void DirectionalDragArea::touchEvent_undecided(QTouchEvent *event)
{
    const QTouchEvent::TouchPoint *touchPoint = fetchTargetTouchPoint(event);
    const QPointF &touchPos = touchPoint->pos();

    if (touchPoint->state() == Qt::TouchPointReleased) {
        // touch has ended before recognition concluded
        setStatus(WaitingForTouch);
        return;
    }

    if (event->touchPointStates().testFlag(Qt::TouchPointPressed)
            || event->touchPoints().count() > 1) {
        // multi-finger drags are not accepted
        setStatus(Rejected);
        return;
    }

    m_previousDampedPos.setX(m_dampedPos.x());
    m_previousDampedPos.setY(m_dampedPos.y());
    m_dampedPos.update(touchPos);

    if (!pointInsideAllowedArea()) {
        setStatus(Rejected);
        return;
    }

    if (!movingInRightDirection()) {
        setStatus(Rejected);
        return;
    }

    setPreviousPos(touchPos);

    if (movedFarEnough(touchPos)) {
        setStatus(Recognized);
    }
}

void DirectionalDragArea::touchEvent_recognized(QTouchEvent *event)
{
    const QTouchEvent::TouchPoint *touchPoint = fetchTargetTouchPoint(event);

    setPreviousPos(touchPoint->pos());

    if (touchPoint->state() == Qt::TouchPointReleased) {
        setStatus(WaitingForTouch);
    }
}

void DirectionalDragArea::touchEvent_rejected(QTouchEvent *event)
{
    const QTouchEvent::TouchPoint *touchPoint = fetchTargetTouchPoint(event);

    if (!touchPoint || touchPoint->state() == Qt::TouchPointReleased) {
        setStatus(WaitingForTouch);
    }
}

const QTouchEvent::TouchPoint *DirectionalDragArea::fetchTargetTouchPoint(QTouchEvent *event)
{
    const QList<QTouchEvent::TouchPoint> &touchPoints = event->touchPoints();
    const QTouchEvent::TouchPoint *touchPoint = 0;
    for (int i = 0; i < touchPoints.size(); ++i) {
        if (touchPoints.at(i).id() == m_touchId) {
            touchPoint = &touchPoints.at(i);
            break;
        }
    }
    return touchPoint;
}

bool DirectionalDragArea::pointInsideAllowedArea() const
{
    qreal dX = m_dampedPos.x() - m_startPos.x();
    qreal dY = m_dampedPos.y() - m_startPos.y();

    switch (m_direction) {
        case Upwards:
            return dY <= 0 && qFabs(dX) <= qFabs(dY) * m_wideningFactor;
        case Downwards:
            return dY >= 0 && qFabs(dX) <= dY * m_wideningFactor;
        case Leftwards:
            return dX <= 0  && qFabs(dY) <= qFabs(dX) * m_wideningFactor;
        default: // Rightwards:
            return dX >= 0 && qFabs(dY) <= dX * m_wideningFactor;
    }
}

bool DirectionalDragArea::movingInRightDirection() const
{
    switch (m_direction) {
        case Upwards:
            return m_dampedPos.y() <= m_previousDampedPos.y();
        case Downwards:
            return m_dampedPos.y() >= m_previousDampedPos.y();
        case Leftwards:
            return m_dampedPos.x() <= m_previousDampedPos.x();
        default: // Rightwards:
            return m_dampedPos.x() >= m_previousDampedPos.x();
    }
}

bool DirectionalDragArea::movedFarEnough(const QPointF &point) const
{
    if (directionIsHorizontal())
        return qFabs(point.x() - m_startPos.x()) > m_distanceThreshold;
    else
        return qFabs(point.y() - m_startPos.y()) > m_distanceThreshold;
}

void DirectionalDragArea::setStatus(DirectionalDragArea::Status newStatus)
{
    if (newStatus == m_status)
        return;

    DirectionalDragArea::Status oldStatus = m_status;

    m_status = newStatus;
    Q_EMIT statusChanged(m_status);

    switch (newStatus) {
        case WaitingForTouch:
            if (oldStatus != DirectionalDragArea::Rejected) {
                Q_EMIT draggingChanged(false);
            }
            break;
        case Undecided:
            Q_EMIT draggingChanged(true);
            break;
        case Rejected:
            Q_EMIT draggingChanged(false);
            break;
        default:
            // no-op
            break;
    }
}

void DirectionalDragArea::setPreviousPos(QPointF point)
{
    Q_ASSERT(m_status != Rejected);

    bool xChanged = m_previousPos.x() != point.x();
    bool yChanged = m_previousPos.y() != point.y();

    m_previousPos = point;

    if (xChanged) {
        Q_EMIT touchXChanged(point.x());
        if (directionIsHorizontal())
            Q_EMIT distanceChanged(distance());
    }

    if (yChanged) {
        Q_EMIT touchYChanged(point.y());
        if (directionIsVertical())
            Q_EMIT distanceChanged(distance());
    }
}

bool DirectionalDragArea::directionIsHorizontal() const
{
    return m_direction == Leftwards || m_direction == Rightwards;
}

bool DirectionalDragArea::directionIsVertical() const
{
    return m_direction == Upwards || m_direction == Downwards;
}
