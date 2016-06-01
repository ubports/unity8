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

#ifndef MOCK_MEDIAPLAYER_H
#define MOCK_MEDIAPLAYER_H

#include <QObject>
#include <QUrl>
#include <QTimer>
#include <QHash>
#include <QVariant>

class MetaDataObject;
class DeclarativePlaylist;

class MediaPlayer: public QObject
{
    Q_OBJECT

    Q_PROPERTY(QUrl source READ source WRITE setSource NOTIFY sourceChanged)
    Q_PROPERTY(PlaybackState playbackState READ playbackState NOTIFY playbackStateChanged)
    Q_PROPERTY(int position READ position NOTIFY positionChanged)
    Q_PROPERTY(int duration READ duration NOTIFY durationChanged)
    Q_PROPERTY(Error error READ error NOTIFY errorChanged)
    Q_PROPERTY(QString errorString READ errorString NOTIFY errorStringChanged)
    Q_PROPERTY(AudioRole audioRole READ audioRole WRITE setAudioRole)

    Q_PROPERTY(bool seekable READ isSeekable NOTIFY seekableChanged)
    Q_PROPERTY(Availability availability READ availability NOTIFY availabilityChanged)
    Q_PROPERTY(Status status READ status NOTIFY statusChanged)
    Q_PROPERTY(QObject *metaData READ metaData CONSTANT)
    Q_PROPERTY(DeclarativePlaylist *playlist READ playlist WRITE setPlaylist NOTIFY playlistChanged)

    Q_ENUMS(PlaybackState)
    Q_ENUMS(AudioRole)
    Q_ENUMS(Availability)
    Q_ENUMS(Status)
    Q_ENUMS(Error)
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

    enum Availability {
        Available,
        Busy,
        Unavailable,
        ResourceMissing
    };

    enum Status {
        UnknownStatus,
        NoMedia,
        Loading,
        Loaded,
        Stalled,
        Buffering,
        Buffered,
        EndOfMedia,
        InvalidMedia
    };

    enum Error {
        NoError,
        ResourceError,
        FormatError,
        NetworkError,
        AccessDeniedError,
        ServiceMissingError
    };

    explicit MediaPlayer(QObject *parent = nullptr);

    QUrl source() const;
    void setSource(const QUrl &source);

    DeclarativePlaylist *playlist() const;
    void setPlaylist(DeclarativePlaylist *playlist);

    PlaybackState playbackState() const;

    int position() const;

    int duration() const;

    Error error() const;
    QString errorString() const;

    AudioRole audioRole() const;
    void setAudioRole(AudioRole audioRole);

    bool isSeekable() const;
    MediaPlayer::Availability availability() const;
    Status status() const { return m_status; }
    QObject *metaData() const;

public Q_SLOTS:
    void pause();
    void play();
    void stop();
    void seek(int position);

Q_SIGNALS:
    void playlistChanged();
    void sourceChanged(const QUrl &source);
    void playbackStateChanged(PlaybackState playbackState);
    void positionChanged(int position);
    void durationChanged(int duration);
    void seekableChanged(bool seekable);
    void errorChanged(Error error);
    void errorStringChanged(const QString &errorString);
    void availabilityChanged(Availability availability);
    void statusChanged();

    void error(Error error, const QString &errorString);

private Q_SLOTS:
    void timerEvent();

private:
    QUrl m_source;
    PlaybackState m_playbackState;
    QTimer m_timer;
    int m_position;
    Status m_status;
    MetaDataObject *m_metaData;
    DeclarativePlaylist *m_playlist;
};

class MediaDataSource : public QObject
{
    Q_OBJECT
    Q_PROPERTY(QUrl source READ source WRITE setSource NOTIFY sourceChanged)
    Q_PROPERTY(bool seekable READ isSeekable WRITE setSeekable NOTIFY seekableChanged)
    Q_PROPERTY(int duration READ duration WRITE setDuration NOTIFY durationChanged)
    Q_PROPERTY(MediaPlayer::Availability availability READ availability WRITE setAvailability NOTIFY availabilityChanged)
    Q_PROPERTY(QVariant metaData READ metaData WRITE setMetaData NOTIFY metaDataChanged)

public:
    MediaDataSource(QObject* parent = 0);
    ~MediaDataSource();

    QUrl source() const { return m_source; }
    void setSource(const QUrl& source);

    bool isSeekable() const { return m_seekable; }
    void setSeekable(bool seekable);

    int duration() const { return m_duration; }
    void setDuration(int duration);

    MediaPlayer::Availability availability() const { return m_availability; }
    void setAvailability(MediaPlayer::Availability availability);

    QVariant metaData() const { return m_metaData; }
    void setMetaData(const QVariant& metaData);

Q_SIGNALS:
    void sourceChanged();
    void seekableChanged(bool seekable);
    void durationChanged(int duration);
    void availabilityChanged(MediaPlayer::Availability availability);
    void metaDataChanged();

private:
    QUrl m_source;
    bool m_seekable;
    int m_duration;
    MediaPlayer::Availability m_availability;
    QVariant m_metaData;
};

class MediaPlayerDataController : public QObject
{
    Q_OBJECT
public:
    MediaPlayerDataController() = default;

    static MediaPlayerDataController *instance();

    void registerDataSource(MediaDataSource* dataSource);
    void unregisterDataSource(MediaDataSource* dataSource);

    MediaDataSource* dataForSource(const QUrl& source);

Q_SIGNALS:
    void sourceAdded(const QUrl& source);
    void sourceAboutToBeRemoved(const QUrl& source);

public:
    QHash<QUrl, MediaDataSource*> m_dataSources;
};

#endif // MOCK_MEDIAPLAYER_H
