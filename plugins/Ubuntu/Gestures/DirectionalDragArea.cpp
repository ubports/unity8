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
#include <QtCore/QTimer>

// Essentially a QTimer wrapper
class RecognitionTimer : public UbuntuGestures::AbstractTimer
{
    Q_OBJECT
public:
    RecognitionTimer(QObject *parent) : UbuntuGestures::AbstractTimer(parent) {
        m_timer.setSingleShot(false);
        connect(&m_timer, &QTimer::timeout,
                this, &UbuntuGestures::AbstractTimer::timeout);
    }
    virtual int interval() const { return m_timer.interval(); }
    virtual void setInterval(int msecs) { m_timer.setInterval(msecs); }
    virtual void start() { m_timer.start(); UbuntuGestures::AbstractTimer::start(); }
    virtual void stop() { m_timer.stop(); UbuntuGestures::AbstractTimer::stop(); }
private:
    QTimer m_timer;
};

DirectionalDragArea::DirectionalDragArea(QQuickItem *parent)
    : QQuickItem(parent)
    , m_status(WaitingForTouch)
    , m_touchId(-1)
    , m_direction(Direction::Rightwards)
    , m_wideningAngle(0)
    , m_wideningFactor(0)
    , m_distanceThreshold(0)
    , m_minSpeed(0)
    , m_maxSilenceTime(200)
    , m_silenceTime(0)
    , m_numSamplesOnLastSpeedCheck(0)
    , m_recognitionTimer(0)
    , m_velocityCalculator(0)
{
    setRecognitionTimer(new RecognitionTimer(this));
    m_recognitionTimer->setInterval(60);

    m_velocityCalculator = new AxisVelocityCalculator(this);
}

Direction::Type DirectionalDragArea::direction() const
{
    return m_direction;
}

void DirectionalDragArea::setDirection(Direction::Type direction)
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

void DirectionalDragArea::setMinSpeed(qreal value)
{
    if (m_minSpeed != value) {
        m_minSpeed = value;
        Q_EMIT minSpeedChanged(value);
    }
}

void DirectionalDragArea::setMaxSilenceTime(int value)
{
    if (m_maxSilenceTime != value) {
        m_maxSilenceTime = value;
        Q_EMIT maxSilenceTimeChanged(value);
    }
}

void DirectionalDragArea::setRecognitionTimer(UbuntuGestures::AbstractTimer *timer)
{
    int interval = 0;
    bool timerWasRunning = false;

    // can be null when called from the constructor
    if (m_recognitionTimer) {
        interval = m_recognitionTimer->interval();
        timerWasRunning = m_recognitionTimer->isRunning();
        if (m_recognitionTimer->parent() == this) {
            delete m_recognitionTimer;
        }
    }

    m_recognitionTimer = timer;
    timer->setInterval(interval);
    connect(timer, &UbuntuGestures::AbstractTimer::timeout,
            this, &DirectionalDragArea::checkSpeed);
    if (timerWasRunning) {
        m_recognitionTimer->start();
    }
}

void DirectionalDragArea::setTimeSource(UbuntuGestures::TimeSource *timeSource)
{
    m_velocityCalculator->setTimeSource(timeSource);
}

qreal DirectionalDragArea::distance() const
{
    if (Direction::isHorizontal(m_direction)) {
        return m_previousPos.x() - m_startPos.x();
    } else {
        return m_previousPos.y() - m_startPos.y();
    }
}

qreal DirectionalDragArea::sceneDistance() const
{
    if (Direction::isHorizontal(m_direction)) {
        return m_previousScenePos.x() - m_startScenePos.x();
    } else {
        return m_previousScenePos.y() - m_startScenePos.y();
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

qreal DirectionalDragArea::touchSceneX() const
{
    return m_previousScenePos.x();
}

qreal DirectionalDragArea::touchSceneY() const
{
    return m_previousScenePos.y();
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
        const QTouchEvent::TouchPoint &touchPoint = event->touchPoints()[0];
        m_startPos = touchPoint.pos();
        m_startScenePos = touchPoint.scenePos();
        m_touchId = touchPoint.id();
        m_dampedPos.reset(m_startPos);
        updateVelocityCalculator(m_startPos);
        m_velocityCalculator->reset();
        m_numSamplesOnLastSpeedCheck = 0;
        m_silenceTime = 0;
        setPreviousPos(m_startPos);
        setPreviousScenePos(m_startScenePos);

        if (m_distanceThreshold > 0)
            setStatus(Undecided);
        else
            setStatus(Recognized);
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
    updateVelocityCalculator(touchPos);

    if (!pointInsideAllowedArea()) {
        setStatus(Rejected);
        return;
    }

    if (!movingInRightDirection()) {
        setStatus(Rejected);
        return;
    }

    setPreviousPos(touchPos);
    setPreviousScenePos(touchPoint->scenePos());

    if (movedFarEnough(touchPos)) {
        setStatus(Recognized);
    }
}

void DirectionalDragArea::touchEvent_recognized(QTouchEvent *event)
{
    const QTouchEvent::TouchPoint *touchPoint = fetchTargetTouchPoint(event);

    setPreviousPos(touchPoint->pos());
    setPreviousScenePos(touchPoint->scenePos());

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
        case Direction::Upwards:
            return dY <= 0 && qFabs(dX) <= qFabs(dY) * m_wideningFactor;
        case Direction::Downwards:
            return dY >= 0 && qFabs(dX) <= dY * m_wideningFactor;
        case Direction::Leftwards:
            return dX <= 0  && qFabs(dY) <= qFabs(dX) * m_wideningFactor;
        default: // Direction::Rightwards:
            return dX >= 0 && qFabs(dY) <= dX * m_wideningFactor;
    }
}

bool DirectionalDragArea::movingInRightDirection() const
{
    switch (m_direction) {
        case Direction::Upwards:
            return m_dampedPos.y() <= m_previousDampedPos.y();
        case Direction::Downwards:
            return m_dampedPos.y() >= m_previousDampedPos.y();
        case Direction::Leftwards:
            return m_dampedPos.x() <= m_previousDampedPos.x();
        default: // Direction::Rightwards:
            return m_dampedPos.x() >= m_previousDampedPos.x();
    }
}

bool DirectionalDragArea::movedFarEnough(const QPointF &point) const
{
    if (Direction::isHorizontal(m_direction))
        return qFabs(point.x() - m_startPos.x()) > m_distanceThreshold;
    else
        return qFabs(point.y() - m_startPos.y()) > m_distanceThreshold;
}

void DirectionalDragArea::checkSpeed()
{
    if (m_velocityCalculator->numSamples() >= AxisVelocityCalculator::MIN_SAMPLES_NEEDED) {
        qreal speed = qFabs(m_velocityCalculator->calculate());
        qreal minSpeedMsecs = m_minSpeed / 1000.0;

        if (speed < minSpeedMsecs) {
            setStatus(Rejected);
        }
    }

    if (m_velocityCalculator->numSamples() == m_numSamplesOnLastSpeedCheck) {
        m_silenceTime += m_recognitionTimer->interval();

        if (m_silenceTime > m_maxSilenceTime) {
            setStatus(Rejected);
        }
    } else {
        m_silenceTime = 0;
    }
    m_numSamplesOnLastSpeedCheck = m_velocityCalculator->numSamples();
}

void DirectionalDragArea::setStatus(DirectionalDragArea::Status newStatus)
{
    if (newStatus == m_status)
        return;

    DirectionalDragArea::Status oldStatus = m_status;

    if (oldStatus == Undecided) {
        m_recognitionTimer->stop();
    }

    m_status = newStatus;
    Q_EMIT statusChanged(m_status);

    switch (newStatus) {
        case WaitingForTouch:
            if (oldStatus != DirectionalDragArea::Rejected) {
                Q_EMIT draggingChanged(false);
            }
            break;
        case Undecided:
            m_recognitionTimer->start();
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
        if (Direction::isHorizontal(m_direction))
            Q_EMIT distanceChanged(distance());
    }

    if (yChanged) {
        Q_EMIT touchYChanged(point.y());
        if (Direction::isVertical(m_direction))
            Q_EMIT distanceChanged(distance());
    }
}

void DirectionalDragArea::setPreviousScenePos(QPointF point)
{
    Q_ASSERT(m_status != Rejected);

    bool xChanged = m_previousScenePos.x() != point.x();
    bool yChanged = m_previousScenePos.y() != point.y();

    m_previousScenePos = point;

    if (xChanged) {
        Q_EMIT touchSceneXChanged(point.x());
        if (Direction::isHorizontal(m_direction))
            Q_EMIT sceneDistanceChanged(sceneDistance());
    }

    if (yChanged) {
        Q_EMIT touchSceneYChanged(point.y());
        if (Direction::isVertical(m_direction))
            Q_EMIT sceneDistanceChanged(sceneDistance());
    }
}

void DirectionalDragArea::updateVelocityCalculator(QPointF point)
{
    if (Direction::isHorizontal(m_direction)) {
        m_velocityCalculator->setTrackedPosition(point.x());
    } else {
        m_velocityCalculator->setTrackedPosition(point.y());
    }
}

// Because we are defining a new QObject-based class (RecognitionTimer) here.
#include "DirectionalDragArea.moc"
