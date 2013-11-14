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
 *
 * Author: Michael Zanetti <michael.zanetti@canonical.com>
 */

#include "audio.h"

Audio::Audio(QObject* parent):
    QObject(parent),
    m_playbackState(StoppedState)
{
}

QUrl Audio::source() const
{
    return m_source;
}

void Audio::setSource(const QUrl &source)
{
    if (m_source != source) {
        m_source = source;
        Q_EMIT sourceChanged(source);
    }
}

Audio::PlaybackState Audio::playbackState() const
{
    return m_playbackState;
}

QString Audio::errorString() const
{
    return QString();
}

void Audio::pause()
{
    if (m_playbackState == PlayingState) {
        m_playbackState = PausedState;
        Q_EMIT playbackStateChanged();
    }
}

void Audio::play()
{
    if (m_playbackState != PlayingState && m_source.isValid()) {
        m_playbackState = PlayingState;
        Q_EMIT playbackStateChanged();
    }
}

void Audio::stop()
{
    if (m_playbackState != StoppedState) {
        m_playbackState = StoppedState;
        Q_EMIT playbackStateChanged();
    }
}
