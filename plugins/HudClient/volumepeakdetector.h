/*
 * Copyright (C) 2012, 2013 Canonical, Ltd.
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

#ifndef VOLUMEPEAKDETECTOR_H
#define VOLUMEPEAKDETECTOR_H

#include <QObject>

#include <QThread>

#include <pulse/pulseaudio.h>

class PulseAudioVolumePeakDetector : public QObject
{
    Q_OBJECT

public:
    PulseAudioVolumePeakDetector();

    int nAccumulatedValuesLimit() const;
    void setNAccumulatedValuesLimit(int limit);

    void startStream();
    void processData();
    void quit();

public Q_SLOTS:
    void start();

Q_SIGNALS:
    void newPeak(float value);

private:
    float m_accumulatedValue;
    int m_nAccumulatedValues;
    int m_accumulatedValuesLimit;
    pa_context *m_context;
    pa_mainloop_api *m_mainloop_api;
    pa_stream *m_stream;
};

class VolumePeakDetector : public QObject
{
    Q_OBJECT
    Q_PROPERTY(bool enabled READ enabled WRITE setEnabled)
    Q_PROPERTY(int desiredInterval READ desiredInterval WRITE setDesiredInterval)

public:
    VolumePeakDetector();

    bool enabled() const;
    void setEnabled(int enabled);

    int desiredInterval() const;
    void setDesiredInterval(int interval);

Q_SIGNALS:
    void newPeak(float volume);

private:
    QThread m_thread;
    PulseAudioVolumePeakDetector m_volumeDetector;
};

#endif
