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

#include "volumepeakdetector.h"

static void stream_read_callback(pa_stream * /*s*/, size_t /*length*/, void *userdata) {
    PulseAudioVolumePeakDetector *peakDetector = static_cast<PulseAudioVolumePeakDetector *>(userdata);
    peakDetector->processData();
}

static void context_state_callback(pa_context *c, void *userdata) {
    PulseAudioVolumePeakDetector *peakDetector = static_cast<PulseAudioVolumePeakDetector *>(userdata);

    switch (pa_context_get_state(c)) {
        case PA_CONTEXT_CONNECTING:
        case PA_CONTEXT_AUTHORIZING:
        case PA_CONTEXT_SETTING_NAME:
            break;

        case PA_CONTEXT_READY:
            peakDetector->startStream();
            break;

        case PA_CONTEXT_TERMINATED:
        case PA_CONTEXT_FAILED:
        default:
            peakDetector->quit();
    }
}

PulseAudioVolumePeakDetector::PulseAudioVolumePeakDetector()
 : m_accumulatedValue(0)
 , m_nAccumulatedValues(0)
 , m_accumulatedValuesLimit(1)
 , m_context(nullptr)
 , m_mainloop_api(nullptr)
 , m_stream(nullptr)
{
}

void PulseAudioVolumePeakDetector::start()
{
    pa_mainloop *mainloop = nullptr;

    /* Set up a new main loop */
    mainloop = pa_mainloop_new();
    if (!mainloop)
        return;

    m_mainloop_api = pa_mainloop_get_api(mainloop);

    /* Create a new connection context */
    m_context = pa_context_new(m_mainloop_api, nullptr);
    if (!m_context) {
        goto quit;
    }

    pa_context_set_state_callback(m_context, context_state_callback, this);

    /* Connect the context */
    if (pa_context_connect(m_context, nullptr, PA_CONTEXT_NOFLAGS, nullptr) < 0) {
        goto quit;
    }

    /* Run the main loop */
    if (pa_mainloop_run(mainloop, nullptr) < 0) {
        goto quit;
    }

quit:
    if (m_stream)
        pa_stream_unref(m_stream);

    if (m_context)
        pa_context_unref(m_context);

    if (mainloop) {
        pa_signal_done();
        pa_mainloop_free(mainloop);
    }

    QThread::currentThread()->quit();
}

int PulseAudioVolumePeakDetector::nAccumulatedValuesLimit() const
{
    return m_accumulatedValuesLimit;
}

void PulseAudioVolumePeakDetector::setNAccumulatedValuesLimit(int limit)
{
    m_accumulatedValuesLimit = limit;
}

// FIXME 16000 is hardcoded because julius needs it
// and the hardware/driver/pulse something gets confused
// if we use different rates
// We would be happier with a much smaller value like 100
static uint voice_needed_rate = 16000;

void PulseAudioVolumePeakDetector::startStream()
{
    pa_buffer_attr buffer_attr;
    pa_proplist *proplist = pa_proplist_new();

    // FIXME 16000 is hardcoded because julius needs it
    // and the hardware/driver/pulse something gets confused
    // if we use different rates
    // We would be happier with a much smaller value like 100
    pa_sample_spec sample_spec;
    sample_spec.format = PA_SAMPLE_FLOAT32;
    sample_spec.rate = 16000;
    sample_spec.channels = 1;

    pa_channel_map channel_map;

    pa_channel_map_init_extend(&channel_map, sample_spec.channels, PA_CHANNEL_MAP_DEFAULT);
    pa_proplist_sets(proplist, PA_PROP_MEDIA_NAME, "HUD Peak Detector");

    m_stream = pa_stream_new_with_proplist(m_context, nullptr, &sample_spec, &channel_map, proplist);
    if (!m_stream) {
        pa_proplist_free(proplist);
        quit();
        return;
    }
    pa_proplist_free(proplist);

    pa_stream_set_read_callback(m_stream, stream_read_callback, this);

    memset(&buffer_attr, 0, sizeof(buffer_attr));
    buffer_attr.maxlength = (uint32_t) -1;
    buffer_attr.fragsize = sizeof(float);

    if (pa_stream_connect_record(m_stream, nullptr, &buffer_attr, (pa_stream_flags_t)(PA_STREAM_PEAK_DETECT | PA_STREAM_ADJUST_LATENCY)) < 0) {
        quit();
    }
}

void PulseAudioVolumePeakDetector::processData()
{
    while (pa_stream_readable_size(m_stream) > 0) {
        const void *data;
        size_t length;

        if (pa_stream_peek(m_stream, &data, &length) < 0) {
            quit();
            return;
        }

        const float *values = (float*)data;
        for (size_t i = 0; i < length / sizeof(float); ++i) {
            float value = values[i];
            if (value < 0) value = 0;
            if (value > 1) value = 1;
            m_nAccumulatedValues++;
            m_accumulatedValue += value;
            if (m_nAccumulatedValues == m_accumulatedValuesLimit) {
                Q_EMIT newPeak(m_accumulatedValue / m_nAccumulatedValues);
                m_nAccumulatedValues = 0;
                m_accumulatedValue = 0;
            }
        }

        pa_stream_drop(m_stream);
    }
}

void PulseAudioVolumePeakDetector::quit()
{
    m_mainloop_api->quit(m_mainloop_api, 0);
}


/* VolumePeakDetector */

VolumePeakDetector::VolumePeakDetector()
{
    QObject::connect(&m_thread, SIGNAL(started()), &m_volumeDetector, SLOT(start()));
    QObject::connect(&m_volumeDetector, SIGNAL(newPeak(float)), this, SIGNAL(newPeak(float)));

    m_volumeDetector.moveToThread(&m_thread);
}

bool VolumePeakDetector::enabled() const
{
    return m_thread.isRunning();
}

int VolumePeakDetector::desiredInterval() const
{
    return m_volumeDetector.nAccumulatedValuesLimit() * 1000 / voice_needed_rate;
}

void VolumePeakDetector::setDesiredInterval(int interval)
{
    m_volumeDetector.setNAccumulatedValuesLimit(voice_needed_rate * interval / 1000);
}

void VolumePeakDetector::setEnabled(int enabled)
{
    if (enabled) {
        if (!m_thread.isRunning()) {
            m_thread.start();
        }
    } else {
        if (m_thread.isRunning()) {
            m_volumeDetector.quit();
        }
    }
}
