/*
 * Copyright (C) 2012-2016 Canonical, Ltd.
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
 */

#ifndef MOCK_AUDIO_H
#define MOCK_AUDIO_H

#include <QObject>
#include <QUrl>
#include <QTimer>

class DeclarativePlaylist;

class Audio: public QObject
{
    Q_OBJECT
    Q_ENUMS(PlaybackState)
    Q_ENUMS(AudioRole)
    Q_PROPERTY(QUrl source READ source WRITE setSource NOTIFY sourceChanged)
    Q_PROPERTY(PlaybackState playbackState READ playbackState NOTIFY playbackStateChanged)
    Q_PROPERTY(int position READ position NOTIFY positionChanged)
    Q_PROPERTY(int duration READ duration NOTIFY durationChanged)
    Q_PROPERTY(QString errorString READ errorString NOTIFY errorStringChanged)
    Q_PROPERTY(AudioRole audioRole READ audioRole WRITE setAudioRole)
    Q_PROPERTY(DeclarativePlaylist *playlist READ playlist WRITE setPlaylist NOTIFY playlistChanged)
public:
    enum PlaybackState {
        PlayingState,
        PausedState,
        StoppedState
    };

    enum AudioRole {
        UnknownRole,
        MusicRole,
        VideoRole,
        VoiceCommunicationRole,
        AlarmRole,
        NotificationRole,
        RingtoneRole,
        AccessibilityRole,
        SonificationRole,
        GameRole
    };

    explicit Audio(QObject *parent = nullptr);

    QUrl source() const;
    void setSource(const QUrl &source);

    DeclarativePlaylist *playlist() const;
    void setPlaylist(DeclarativePlaylist *playlist);

    PlaybackState playbackState() const;

    int position() const;

    int duration() const;

    QString errorString() const;

    AudioRole audioRole() const;
    void setAudioRole(AudioRole audioRole);

public Q_SLOTS:
    void pause();
    void play();
    void stop();

Q_SIGNALS:
    void playlistChanged();
    void sourceChanged(const QUrl &source);
    void playbackStateChanged(PlaybackState playbackState);
    void positionChanged(int position);
    void durationChanged(int duration);
    void errorStringChanged(const QString &errorString);

private Q_SLOTS:
    void timerEvent();

private:
    QUrl m_source;
    PlaybackState m_playbackState;
    QTimer m_timer;
    int m_position;
    int m_duration;
    DeclarativePlaylist *m_playlist;
};

#endif
