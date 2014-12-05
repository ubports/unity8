/*
 * Copyright (C) 2013-2014 Canonical, Ltd.
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

#define ACTIVETOUCHESINFO_DEBUG 0
#define DIRECTIONALDRAGAREA_DEBUG 0

#include "DirectionalDragArea.h"

#include <QQuickWindow>
#include <QtCore/qmath.h>
#include <QDebug>

#pragma GCC diagnostic push
#pragma GCC diagnostic ignored "-pedantic"
#include <private/qquickwindow_p.h>
#pragma GCC diagnostic pop

// local
#include "TouchOwnershipEvent.h"
#include "TouchRegistry.h"
#include "UnownedTouchEvent.h"

using namespace UbuntuGestures;

#if DIRECTIONALDRAGAREA_DEBUG
#define ddaDebug(params) qDebug().nospace() << "[DDA(" << qPrintable(objectName()) << ")] " << params
#include "DebugHelpers.h"

namespace {
const char *statusToString(DirectionalDragArea::Status status)
{
    if (status == DirectionalDragArea::WaitingForTouch) {
        return "WaitingForTouch";
    } else if (status == DirectionalDragArea::Undecided) {
        return "Undecided";
    } else {
        return "Recognized";
    }
}

} // namespace {
#else // DIRECTIONALDRAGAREA_DEBUG
#define ddaDebug(params) ((void)0)
#endif // DIRECTIONALDRAGAREA_DEBUG


DirectionalDragArea::DirectionalDragArea(QQuickItem *parent)
    : QQuickItem(parent)
    , m_status(WaitingForTouch)
    , m_sceneDistance(0)
    , m_touchId(-1)
    , m_direction(Direction::Rightwards)
    , m_wideningAngle(0)
    , m_wideningFactor(0)
    , m_distanceThreshold(0)
    , m_distanceThresholdSquared(0.)
    , m_minSpeed(0)
    , m_maxSilenceTime(200)
    , m_silenceTime(0)
    , m_compositionTime(60)
    , m_numSamplesOnLastSpeedCheck(0)
    , m_recognitionTimer(0)
    , m_velocityCalculator(0)
    , m_timeSource(new RealTimeSource)
    , m_activeTouches(m_timeSource)
{
    setRecognitionTimer(new Timer(this));
    m_recognitionTimer->setInterval(60);
    m_recognitionTimer->setSingleShot(false);

    m_velocityCalculator = new AxisVelocityCalculator(this);

    connect(this, &QQuickItem::enabledChanged, this, &DirectionalDragArea::giveUpIfDisabledOrInvisible);
    connect(this, &QQuickItem::visibleChanged, this, &DirectionalDragArea::giveUpIfDisabledOrInvisible);
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
    if (m_dampedScenePos.maxDelta() != value) {
        m_dampedScenePos.setMaxDelta(value);
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

    // wideningFactor = pow(cosine(angle), 2)
    {
        qreal angleRadians = angle * M_PI / 180.0;
        m_wideningFactor = qCos(angleRadians);
        m_wideningFactor = m_wideningFactor * m_wideningFactor;
    }

    Q_EMIT wideningAngleChanged(angle);
}

void DirectionalDragArea::setDistanceThreshold(qreal value)
{
    if (m_distanceThreshold != value) {
        m_distanceThreshold = value;
        m_distanceThresholdSquared = m_distanceThreshold * m_distanceThreshold;
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

void DirectionalDragArea::setCompositionTime(int value)
{
    if (m_compositionTime != value) {
        m_compositionTime = value;
        Q_EMIT compositionTimeChanged(value);
    }
}

void DirectionalDragArea::setRecognitionTimer(UbuntuGestures::AbstractTimer *timer)
{
    int interval = 0;
    bool timerWasRunning = false;
    bool wasSingleShot = false;

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
    timer->setSingleShot(wasSingleShot);
    connect(timer, &UbuntuGestures::AbstractTimer::timeout,
            this, &DirectionalDragArea::checkSpeed);
    if (timerWasRunning) {
        m_recognitionTimer->start();
    }
}

void DirectionalDragArea::setTimeSource(const SharedTimeSource &timeSource)
{
    m_timeSource = timeSource;
    m_velocityCalculator->setTimeSource(timeSource);
    m_activeTouches.m_timeSource = timeSource;
}

qreal DirectionalDragArea::distance() const
{
    if (Direction::isHorizontal(m_direction)) {
        return m_previousPos.x() - m_startPos.x();
    } else {
        return m_previousPos.y() - m_startPos.y();
    }
}

void DirectionalDragArea::updateSceneDistance()
{
    QPointF totalMovement = m_previousScenePos - m_startScenePos;
    m_sceneDistance = projectOntoDirectionVector(totalMovement);
}

qreal DirectionalDragArea::sceneDistance() const
{
    return m_sceneDistance;
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

bool DirectionalDragArea::event(QEvent *event)
{
    if (event->type() == TouchOwnershipEvent::touchOwnershipEventType()) {
        touchOwnershipEvent(static_cast<TouchOwnershipEvent *>(event));
        return true;
    } else if (event->type() == UnownedTouchEvent::unownedTouchEventType()) {
        unownedTouchEvent(static_cast<UnownedTouchEvent *>(event));
        return true;
    } else {
        return QQuickItem::event(event);
    }
}

void DirectionalDragArea::touchOwnershipEvent(TouchOwnershipEvent *event)
{
    if (event->gained()) {
        QVector<int> ids;
        ids.append(event->touchId());
        ddaDebug("grabbing touch");
        grabTouchPoints(ids);

        // Work around for Qt bug. If we grab a touch that is being used for mouse pointer
        // emulation it will cause the emulation logic to go nuts.
        // Thus we have to also grab the mouse in this case.
        //
        // The fix for this bug has landed in Qt 5.4 (https://codereview.qt-project.org/96887)
        // TODO: Remove this workaround once we start using Qt 5.4
        if (window()) {
            QQuickWindowPrivate *windowPrivate = QQuickWindowPrivate::get(window());
            if (windowPrivate->touchMouseId == event->touchId() && window()->mouseGrabberItem()) {
                ddaDebug("removing mouse grabber");
                window()->mouseGrabberItem()->ungrabMouse();
            }
        }
    } else {
        // We still wanna know when it ends for keeping the composition time window up-to-date
        TouchRegistry::instance()->addTouchWatcher(m_touchId, this);

        setStatus(WaitingForTouch);
    }
}

void DirectionalDragArea::unownedTouchEvent(UnownedTouchEvent *unownedTouchEvent)
{
    QTouchEvent *event = unownedTouchEvent->touchEvent();

    Q_ASSERT(!event->touchPointStates().testFlag(Qt::TouchPointPressed));

    ddaDebug("Unowned " << m_timeSource->msecsSinceReference() << " " << qPrintable(touchEventToString(event)));

    switch (m_status) {
        case WaitingForTouch:
            // do nothing
            break;
        case Undecided:
            Q_ASSERT(isEnabled() && isVisible());
            unownedTouchEvent_undecided(unownedTouchEvent);
            break;
        default: // Recognized:
            // do nothing
            break;
    }

    m_activeTouches.update(event);
}

void DirectionalDragArea::unownedTouchEvent_undecided(UnownedTouchEvent *unownedTouchEvent)
{
    const QTouchEvent::TouchPoint *touchPoint = fetchTargetTouchPoint(unownedTouchEvent->touchEvent());
    if (!touchPoint) {
        qCritical() << "DirectionalDragArea[status=Undecided]: touch " << m_touchId
            << "missing from UnownedTouchEvent without first reaching state Qt::TouchPointReleased. "
               "Considering it as released.";

        TouchRegistry::instance()->removeCandidateOwnerForTouch(m_touchId, this);
        setStatus(WaitingForTouch);
        return;
    }

    const QPointF &touchScenePos = touchPoint->scenePos();

    if (touchPoint->state() == Qt::TouchPointReleased) {
        // touch has ended before recognition concluded
        ddaDebug("Touch has ended before recognition concluded");
        TouchRegistry::instance()->removeCandidateOwnerForTouch(m_touchId, this);
        emitSignalIfTapped();
        setStatus(WaitingForTouch);
        return;
    }

    m_previousDampedScenePos.setX(m_dampedScenePos.x());
    m_previousDampedScenePos.setY(m_dampedScenePos.y());
    m_dampedScenePos.update(touchScenePos);
    updateVelocityCalculator(touchScenePos);

    if (!pointInsideAllowedArea()) {
        ddaDebug("Rejecting gesture because touch point is outside allowed area.");
        TouchRegistry::instance()->removeCandidateOwnerForTouch(m_touchId, this);
        // We still wanna know when it ends for keeping the composition time window up-to-date
        TouchRegistry::instance()->addTouchWatcher(m_touchId, this);
        setStatus(WaitingForTouch);
        return;
    }

    if (!movingInRightDirection()) {
        ddaDebug("Rejecting gesture because touch point is moving in the wrong direction.");
        TouchRegistry::instance()->removeCandidateOwnerForTouch(m_touchId, this);
        // We still wanna know when it ends for keeping the composition time window up-to-date
        TouchRegistry::instance()->addTouchWatcher(m_touchId, this);
        setStatus(WaitingForTouch);
        return;
    }

    setPreviousPos(touchPoint->pos());
    setPreviousScenePos(touchScenePos);

    if (isWithinTouchCompositionWindow()) {
        // There's still time for some new touch to appear and ruin our party as it would be combined
        // with our m_touchId one and therefore deny the possibility of a single-finger gesture.
        ddaDebug("Sill within composition window. Let's wait more.");
        return;
    }

    if (movedFarEnough(touchScenePos)) {
        TouchRegistry::instance()->requestTouchOwnership(m_touchId, this);
        setStatus(Recognized);
    } else {
        ddaDebug("Didn't move far enough yet. Let's wait more.");
    }
}

void DirectionalDragArea::touchEvent(QTouchEvent *event)
{
    // TODO: Consider when more than one touch starts in the same event (although it's not possible
    //       with Mir's android-input). Have to track them all. Consider it a plus/bonus.

    ddaDebug(m_timeSource->msecsSinceReference() << " " << qPrintable(touchEventToString(event)));

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
        default: // Recognized:
            touchEvent_recognized(event);
            break;
    }

    m_activeTouches.update(event);
}

void DirectionalDragArea::touchEvent_absent(QTouchEvent *event)
{
    // TODO: accept/reject is for the whole event, not per touch id. See how that affects us.

    if (!event->touchPointStates().testFlag(Qt::TouchPointPressed)) {
        // Nothing to see here. No touch starting in this event.
        return;
    }

    // to be proven wrong, if that's the case
    bool allGood = true;

    if (isWithinTouchCompositionWindow()) {
        // too close to the last touch start. So we consider them as starting roughly at the same time.
        // Can't be a single-touch gesture.
        ddaDebug("A new touch point came in but we're still within time composition window. Ignoring it.");
        allGood = false;
    }

    const QList<QTouchEvent::TouchPoint> &touchPoints = event->touchPoints();

    const QTouchEvent::TouchPoint *newTouchPoint = nullptr;
    for (int i = 0; i < touchPoints.count() && allGood; ++i) {
        const QTouchEvent::TouchPoint &touchPoint = touchPoints.at(i);
        if (touchPoint.state() == Qt::TouchPointPressed) {
            if (newTouchPoint) {
                // more than one touch starting in this QTouchEvent. Can't be a single-touch gesture
                allGood = false;
            } else {
                // that's our candidate
                m_touchId = touchPoint.id();
                newTouchPoint = &touchPoint;
            }
        }
    }

    if (allGood) {
        Q_ASSERT(newTouchPoint);

        m_startPos = newTouchPoint->pos();
        m_startScenePos = newTouchPoint->scenePos();
        m_touchId = newTouchPoint->id();
        m_dampedScenePos.reset(m_startScenePos);
        m_velocityCalculator->setTrackedPosition(0.);
        m_velocityCalculator->reset();
        m_numSamplesOnLastSpeedCheck = 0;
        m_silenceTime = 0;
        setPreviousPos(m_startPos);
        setPreviousScenePos(m_startScenePos);
        updateSceneDirectionVector();

        if (recognitionIsDisabled()) {
            // Behave like a dumb TouchArea
            ddaDebug("Gesture recognition is disabled. Requesting touch ownership immediately.");
            TouchRegistry::instance()->requestTouchOwnership(m_touchId, this);
            setStatus(Recognized);
            event->accept();
        } else {
            // just monitor the touch points for now.
            TouchRegistry::instance()->addCandidateOwnerForTouch(m_touchId, this);

            setStatus(Undecided);
            // Let the item below have it. We will monitor it and grab it later if a gesture
            // gets recognized.
            event->ignore();
        }
    } else {
        watchPressedTouchPoints(touchPoints);
        event->ignore();
    }
}

void DirectionalDragArea::touchEvent_undecided(QTouchEvent *event)
{
    Q_ASSERT(event->type() == QEvent::TouchBegin);
    Q_ASSERT(fetchTargetTouchPoint(event) == nullptr);

    // We're not interested in new touch points. We already have our candidate (m_touchId).
    // But we do want to know when those new touches end for keeping the composition time
    // window up-to-date
    event->ignore();
    watchPressedTouchPoints(event->touchPoints());

    if (event->touchPointStates().testFlag(Qt::TouchPointPressed) && isWithinTouchCompositionWindow()) {
        // multi-finger drags are not accepted
        ddaDebug("Multi-finger drags are not accepted");

        TouchRegistry::instance()->removeCandidateOwnerForTouch(m_touchId, this);
        // We still wanna know when it ends for keeping the composition time window up-to-date
        TouchRegistry::instance()->addTouchWatcher(m_touchId, this);

        setStatus(WaitingForTouch);
    }
}

void DirectionalDragArea::touchEvent_recognized(QTouchEvent *event)
{
    const QTouchEvent::TouchPoint *touchPoint = fetchTargetTouchPoint(event);

    if (!touchPoint) {
        qCritical() << "DirectionalDragArea[status=Recognized]: touch " << m_touchId
            << "missing from QTouchEvent without first reaching state Qt::TouchPointReleased. "
               "Considering it as released.";
        setStatus(WaitingForTouch);
    } else {
        setPreviousPos(touchPoint->pos());
        setPreviousScenePos(touchPoint->scenePos());

        if (touchPoint->state() == Qt::TouchPointReleased) {
            emitSignalIfTapped();
            setStatus(WaitingForTouch);
        }
    }
}

void DirectionalDragArea::watchPressedTouchPoints(const QList<QTouchEvent::TouchPoint> &touchPoints)
{
    for (int i = 0; i < touchPoints.count(); ++i) {
        const QTouchEvent::TouchPoint &touchPoint = touchPoints.at(i);
        if (touchPoint.state() == Qt::TouchPointPressed) {
            TouchRegistry::instance()->addTouchWatcher(touchPoint.id(), this);
        }
    }
}

bool DirectionalDragArea::recognitionIsDisabled() const
{
    return distanceThreshold() <= 0 && compositionTime() <= 0;
}

void DirectionalDragArea::emitSignalIfTapped()
{
    qint64 touchDuration = m_timeSource->msecsSinceReference() - m_activeTouches.touchStartTime(m_touchId);
    if (touchDuration <= maxTapDuration()) {
        Q_EMIT tapped();
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
    // NB: Using squared values to avoid computing the square root to find
    // the length totalMovement

    QPointF totalMovement(m_dampedScenePos.x() - m_startScenePos.x(),
                          m_dampedScenePos.y() - m_startScenePos.y());

    qreal squaredTotalMovSize = totalMovement.x() * totalMovement.x() +
                                totalMovement.y() * totalMovement.y();

    if (squaredTotalMovSize == 0.) {
        // didn't move
        return true;
    }

    qreal projectedMovement = projectOntoDirectionVector(totalMovement);


    qreal cosineAngleSquared = (projectedMovement * projectedMovement) / squaredTotalMovSize;

    // Same as:
    // angle_between_movement_vector_and_gesture_direction_vector <= widening_angle
    return cosineAngleSquared >= m_wideningFactor;
}

bool DirectionalDragArea::movingInRightDirection() const
{
    if (m_direction == Direction::Horizontal) {
        return true;
    } else {
        QPointF movementVector(m_dampedScenePos.x() - m_previousDampedScenePos.x(),
                               m_dampedScenePos.y() - m_previousDampedScenePos.y());

        qreal scalarProjection = projectOntoDirectionVector(movementVector);

        return scalarProjection >= 0.;
    }
}

bool DirectionalDragArea::movedFarEnough(const QPointF &point) const
{
    if (m_distanceThreshold <= 0.) {
        // distance threshold check is disabled
        return true;
    } else {
        QPointF totalMovement(point.x() - m_startScenePos.x(),
                              point.y() - m_startScenePos.y());

        qreal squaredTotalMovSize = totalMovement.x() * totalMovement.x() +
                                    totalMovement.y() * totalMovement.y();

        return squaredTotalMovSize > m_distanceThresholdSquared;
    }
}

void DirectionalDragArea::checkSpeed()
{
    Q_ASSERT(m_status == Undecided);

    if (m_velocityCalculator->numSamples() >= AxisVelocityCalculator::MIN_SAMPLES_NEEDED) {
        qreal speed = qFabs(m_velocityCalculator->calculate());
        qreal minSpeedMsecs = m_minSpeed / 1000.0;

        if (speed < minSpeedMsecs) {
            ddaDebug("Rejecting gesture because it's below minimum speed.");
            TouchRegistry::instance()->removeCandidateOwnerForTouch(m_touchId, this);
            TouchRegistry::instance()->addTouchWatcher(m_touchId, this);
            setStatus(WaitingForTouch);
        }
    }

    if (m_velocityCalculator->numSamples() == m_numSamplesOnLastSpeedCheck) {
        m_silenceTime += m_recognitionTimer->interval();

        if (m_silenceTime > m_maxSilenceTime) {
            ddaDebug("Rejecting gesture because its silence time has been exceeded.");
            TouchRegistry::instance()->removeCandidateOwnerForTouch(m_touchId, this);
            TouchRegistry::instance()->addTouchWatcher(m_touchId, this);
            setStatus(WaitingForTouch);
        }
    } else {
        m_silenceTime = 0;
    }
    m_numSamplesOnLastSpeedCheck = m_velocityCalculator->numSamples();
}

void DirectionalDragArea::giveUpIfDisabledOrInvisible()
{
    if (!isEnabled() || !isVisible()) {
        if (m_status == Undecided) {
            TouchRegistry::instance()->removeCandidateOwnerForTouch(m_touchId, this);
            // We still wanna know when it ends for keeping the composition time window up-to-date
            TouchRegistry::instance()->addTouchWatcher(m_touchId, this);
        }

        if (m_status != WaitingForTouch) {
            ddaDebug("Resetting status because got disabled or made invisible");
            setStatus(WaitingForTouch);
        }
    }
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

    ddaDebug(statusToString(oldStatus) << " -> " << statusToString(newStatus));

    switch (newStatus) {
        case WaitingForTouch:
            Q_EMIT draggingChanged(false);
            break;
        case Undecided:
            m_recognitionTimer->start();
            Q_EMIT draggingChanged(true);
            break;
        case Recognized:
            if (oldStatus == WaitingForTouch)
                Q_EMIT draggingChanged(true);
            break;
        default:
            // no-op
            break;
    }
}

void DirectionalDragArea::setPreviousPos(const QPointF &point)
{
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

void DirectionalDragArea::setPreviousScenePos(const QPointF &point)
{
    bool xChanged = m_previousScenePos.x() != point.x();
    bool yChanged = m_previousScenePos.y() != point.y();

    if (!xChanged && !yChanged)
        return;

    qreal oldSceneDistance = sceneDistance();
    m_previousScenePos = point;
    updateSceneDistance();

    if (oldSceneDistance != sceneDistance()) {
        Q_EMIT sceneDistanceChanged(sceneDistance());
    }

    if (xChanged) {
        Q_EMIT touchSceneXChanged(point.x());
    }

    if (yChanged) {
        Q_EMIT touchSceneYChanged(point.y());
    }
}

void DirectionalDragArea::updateVelocityCalculator(const QPointF &scenePos)
{
    QPointF totalSceneMovement = scenePos - m_startScenePos;

    qreal scalarProjection = projectOntoDirectionVector(totalSceneMovement);

    m_velocityCalculator->setTrackedPosition(scalarProjection);
}

bool DirectionalDragArea::isWithinTouchCompositionWindow()
{
    return
        compositionTime() > 0 &&
        !m_activeTouches.isEmpty() &&
        m_timeSource->msecsSinceReference() <=
            m_activeTouches.mostRecentStartTime() + (qint64)compositionTime();
}

//**************************  ActiveTouchesInfo **************************

DirectionalDragArea::ActiveTouchesInfo::ActiveTouchesInfo(const SharedTimeSource &timeSource)
    : m_timeSource(timeSource)
{
}

void DirectionalDragArea::ActiveTouchesInfo::update(QTouchEvent *event)
{
    if (!(event->touchPointStates() & (Qt::TouchPointPressed | Qt::TouchPointReleased))) {
        // nothing to update
        #if ACTIVETOUCHESINFO_DEBUG
        qDebug("[DDA::ActiveTouchesInfo] Nothing to Update");
        #endif
        return;
    }

    const QList<QTouchEvent::TouchPoint> &touchPoints = event->touchPoints();
    for (int i = 0; i < touchPoints.count(); ++i) {
        const QTouchEvent::TouchPoint &touchPoint = touchPoints.at(i);
        if (touchPoint.state() == Qt::TouchPointPressed) {
            addTouchPoint(touchPoint.id());
        } else if (touchPoint.state() == Qt::TouchPointReleased) {
            removeTouchPoint(touchPoint.id());
        }
    }
}

#if ACTIVETOUCHESINFO_DEBUG
QString DirectionalDragArea::ActiveTouchesInfo::toString()
{
    QString string = "(";

    {
        QTextStream stream(&string);
        m_touchInfoPool.forEach([&](Pool<ActiveTouchInfo>::Iterator &touchInfo) {
            stream << "(id=" << touchInfo->id << ",startTime=" << touchInfo->startTime << ")";
            return true;
        });
    }

    string.append(")");

    return string;
}
#endif // ACTIVETOUCHESINFO_DEBUG

void DirectionalDragArea::ActiveTouchesInfo::addTouchPoint(int touchId)
{
    ActiveTouchInfo &activeTouchInfo = m_touchInfoPool.getEmptySlot();
    activeTouchInfo.id = touchId;
    activeTouchInfo.startTime = m_timeSource->msecsSinceReference();

    #if ACTIVETOUCHESINFO_DEBUG
    qDebug() << "[DDA::ActiveTouchesInfo]" << qPrintable(toString());
    #endif
}

qint64 DirectionalDragArea::ActiveTouchesInfo::touchStartTime(int touchId)
{
    qint64 result = -1;

    m_touchInfoPool.forEach([&](Pool<ActiveTouchInfo>::Iterator &touchInfo) {
        if (touchId == touchInfo->id) {
            result = touchInfo->startTime;
            return false;
        } else {
            return true;
        }
    });

    Q_ASSERT(result != -1);
    return result;
}

void DirectionalDragArea::ActiveTouchesInfo::removeTouchPoint(int touchId)
{
    m_touchInfoPool.forEach([&](Pool<ActiveTouchInfo>::Iterator &touchInfo) {
        if (touchId == touchInfo->id) {
            m_touchInfoPool.freeSlot(touchInfo);
            return false;
        } else {
            return true;
        }
    });

    #if ACTIVETOUCHESINFO_DEBUG
    qDebug() << "[DDA::ActiveTouchesInfo]" << qPrintable(toString());
    #endif
}

qint64 DirectionalDragArea::ActiveTouchesInfo::mostRecentStartTime()
{
    Q_ASSERT(!m_touchInfoPool.isEmpty());

    qint64 highestStartTime = -1;

    m_touchInfoPool.forEach([&](Pool<ActiveTouchInfo>::Iterator &activeTouchInfo) {
        if (activeTouchInfo->startTime > highestStartTime) {
            highestStartTime = activeTouchInfo->startTime;
        }
        return true;
    });

    return highestStartTime;
}

void DirectionalDragArea::updateSceneDirectionVector()
{
    QPointF localOrigin(0., 0.);
    QPointF localDirection;
    switch (m_direction) {
        case Direction::Upwards:
            localDirection.rx() = 0.;
            localDirection.ry() = -1.;
            break;
        case Direction::Downwards:
            localDirection.rx() = 0.;
            localDirection.ry() = 1;
            break;
        case Direction::Leftwards:
            localDirection.rx() = -1.;
            localDirection.ry() = 0.;
            break;
        default: // Direction::Rightwards || Direction.Horizontal
            localDirection.rx() = 1.;
            localDirection.ry() = 0.;
            break;
    }
    QPointF sceneOrigin = mapToScene(localOrigin);
    QPointF sceneDirection = mapToScene(localDirection);
    m_sceneDirectionVector = sceneDirection - sceneOrigin;
}

qreal DirectionalDragArea::projectOntoDirectionVector(const QPointF &sceneVector) const
{
    // same as dot product as m_sceneDirectionVector is a unit vector
    return  sceneVector.x() * m_sceneDirectionVector.x() +
            sceneVector.y() * m_sceneDirectionVector.y();
}

// Because we are defining a new QObject-based class (RecognitionTimer) here.
#include "DirectionalDragArea.moc"
