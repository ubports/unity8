/*
 * Copyright (C) 2013 - Canonical Ltd.
 *
 * This program is free software: you can redistribute it and/or modify it
 * under the terms of the GNU Lesser General Public License, as
 * published by the  Free Software Foundation; either version 2.1 or 3.0
 * of the License.
 *
 * This program is distributed in the hope that it will be useful, but
 * WITHOUT ANY WARRANTY; without even the implied warranties of
 * MERCHANTABILITY, SATISFACTORY QUALITY or FITNESS FOR A PARTICULAR
 * PURPOSE.  See the applicable version of the GNU Lesser General Public
 * License for more details.
 *
 * You should have received a copy of both the GNU Lesser General Public
 * License along with this program. If not, see <http://www.gnu.org/licenses/>
 *
 * Authored by: Daniel d'Andrada <daniel.dandrada@canonical.com>
 */

#include "AxisVelocityCalculator.h"
#include <QtCore/QElapsedTimer>

class RealTimeSource : public UbuntuGestures::TimeSource {
public:
    RealTimeSource()
        : UbuntuGestures::TimeSource() {
        m_timer.start();
    }
    virtual qint64 msecsSinceReference() {
        return m_timer.elapsed();
    }
private:
    QElapsedTimer m_timer;
};

AxisVelocityCalculator::AxisVelocityCalculator(QObject *parent)
    : QObject(parent)
    , m_timeSource(new RealTimeSource)
    , m_trackedPosition(0.0)
{
    m_timeSource->setParent(this);
    reset();
}

AxisVelocityCalculator::~AxisVelocityCalculator()
{
}

qreal AxisVelocityCalculator::trackedPosition() const
{
    return m_trackedPosition;
}

void AxisVelocityCalculator::setTrackedPosition(qreal newPosition)
{
    processMovement(newPosition - m_trackedPosition);

    if (newPosition != m_trackedPosition) {
        m_trackedPosition = newPosition;
        Q_EMIT trackedPositionChanged(newPosition);
    }
}

void AxisVelocityCalculator::updateIdleTime()
{
    processMovement(0);
}

void AxisVelocityCalculator::processMovement(qreal movement)
{
    if (m_samplesRead == -1) {
        m_samplesRead = m_samplesWrite;
    } else if (m_samplesRead == m_samplesWrite) {
        /* the oldest value is going to be overwritten.
           so now the oldest will be the next one. */
        m_samplesRead = (m_samplesRead + 1) % MAX_SAMPLES;
    }

    m_samples[m_samplesWrite].mov = movement;
    m_samples[m_samplesWrite].time = m_timeSource->msecsSinceReference();
    m_samplesWrite = (m_samplesWrite + 1) % MAX_SAMPLES;
}

qreal AxisVelocityCalculator::calculate()
{
    if (numSamples() < MIN_SAMPLES_NEEDED) {
        return 0.0;
    }
    updateIdleTime(); // consider the time elapsed since the last update and now

    int lastIndex;
    if (m_samplesWrite == 0) {
        lastIndex = MAX_SAMPLES - 1;
    } else {
        lastIndex = m_samplesWrite - 1;
    }

    qint64 currTime = m_samples[lastIndex].time;

    qreal totalTime = 0;
    qreal totalDistance = 0;

    int sampleIndex = (m_samplesRead + 1) % MAX_SAMPLES;
    qint64 previousTime = m_samples[m_samplesRead].time;
    while (sampleIndex != m_samplesWrite) {
        // Skip this sample if it's too old
        if (currTime - m_samples[sampleIndex].time <= AGE_OLDEST_SAMPLE) {
            int deltaTime = m_samples[sampleIndex].time - previousTime;
            totalDistance += m_samples[sampleIndex].mov;
            totalTime += deltaTime;
        }

        previousTime = m_samples[sampleIndex].time;
        sampleIndex = (sampleIndex + 1) % MAX_SAMPLES;
    }

    return totalDistance / totalTime;
}

void AxisVelocityCalculator::reset()
{
    m_samplesRead = -1;
    m_samplesWrite = 0;
}

int AxisVelocityCalculator::numSamples() const
{
    if (m_samplesRead == -1) {
        return 0;
    } else {
        if (m_samplesWrite == 0) {
            /* consider only what's to the right of m_samplesRead (including himself) */
            return MAX_SAMPLES - m_samplesRead;
        } else if (m_samplesWrite == m_samplesRead) {
            return MAX_SAMPLES; /* buffer is full */
        } else if (m_samplesWrite < m_samplesRead) {
            return (MAX_SAMPLES - m_samplesRead) + m_samplesWrite;
        } else {
            return m_samplesWrite - m_samplesRead;
        }
    }
}

void AxisVelocityCalculator::setTimeSource(UbuntuGestures::TimeSource *timeSource)
{
    if (m_timeSource && m_timeSource->parent() == this)
        delete m_timeSource;

    m_timeSource = timeSource;
}
