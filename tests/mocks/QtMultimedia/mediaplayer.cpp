/*
 * Copyright (C) 2013-2016 Canonical, Ltd.
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

#include "mediaplayer.h"

#include <QDebug>
#include <QSize>

class MetaDataObject: public QObject
{
    Q_OBJECT
    Q_PROPERTY(QVariant title READ title NOTIFY metaDataChanged)
    Q_PROPERTY(QVariant resolution READ resolution NOTIFY metaDataChanged)
public:
    MetaDataObject(MediaPlayer* parent = nullptr)
        : QObject(parent)
        , m_source(parent)
    {
    }

    QVariant title() const { return getProperty("title"); }
    QVariant resolution() const { return getProperty("resolution", QSize(640, 640)); }

    QVariant getProperty(const QString& property, QVariant defaultValue = QVariant()) const {
        MediaDataSource* sourceData = MediaPlayerDataController::instance()->dataForSource(m_source->source());
        QVariant metaData = sourceData->metaData();
        return metaData.toMap().value(property, defaultValue);
    }

Q_SIGNALS:
    void metaDataChanged();

private:
    MediaPlayer* m_source;
};

MediaPlayer::MediaPlayer(QObject* parent)
    : QObject(parent)
    , m_playbackState(StoppedState)
    , m_status(NoMedia)
    , m_metaData(new MetaDataObject(this))
    , m_playlist(nullptr)
{
    qsrand(time(nullptr));
    m_timer.setInterval(100);
    connect(&m_timer, &QTimer::timeout, this, &MediaPlayer::timerEvent);

    connect(MediaPlayerDataController::instance(), &MediaPlayerDataController::sourceAboutToBeRemoved,
            this, [this](const QUrl& source) {
        MediaDataSource* dataSource = MediaPlayerDataController::instance()->dataForSource(source);
        if (!dataSource) return;

        disconnect(dataSource, &MediaDataSource::durationChanged, this, &MediaPlayer::durationChanged);
        disconnect(dataSource, &MediaDataSource::seekableChanged, this, &MediaPlayer::seekableChanged);
        disconnect(dataSource, &MediaDataSource::availabilityChanged, this, &MediaPlayer::availabilityChanged);
        disconnect(dataSource, &MediaDataSource::metaDataChanged, m_metaData, &MetaDataObject::metaDataChanged);
    });

    connect(MediaPlayerDataController::instance(), &MediaPlayerDataController::sourceAdded,
            this, [this](const QUrl& source) {
        MediaDataSource* dataSource = MediaPlayerDataController::instance()->dataForSource(source);
        if (!dataSource) return;

        connect(dataSource, &MediaDataSource::durationChanged, this, &MediaPlayer::durationChanged);
        connect(dataSource, &MediaDataSource::seekableChanged,this, &MediaPlayer::seekableChanged);
        connect(dataSource, &MediaDataSource::availabilityChanged,this, &MediaPlayer::availabilityChanged);
        connect(dataSource, &MediaDataSource::metaDataChanged, m_metaData, &MetaDataObject::metaDataChanged);
    });
}

QUrl MediaPlayer::source() const
{
    return m_source;
}

void MediaPlayer::setSource(const QUrl &source)
{
    if (m_source != source) {
        m_source = source;
        Q_EMIT sourceChanged(source);
        Q_EMIT durationChanged(duration());
        Q_EMIT seekableChanged(isSeekable());
        Q_EMIT availabilityChanged(availability());

        m_position = 0;
        Q_EMIT positionChanged(m_position);
        Q_EMIT m_metaData->metaDataChanged();

        m_status = availability()==Available ? Loaded : InvalidMedia;
        Q_EMIT statusChanged();
    }
}

DeclarativePlaylist *MediaPlayer::playlist() const
{
    return m_playlist;
}

void MediaPlayer::setPlaylist(DeclarativePlaylist *playlist)
{
    if (playlist == m_playlist)
        return;

    m_playlist = playlist;
    Q_EMIT playlistChanged();
}

MediaPlayer::PlaybackState MediaPlayer::playbackState() const
{
    return m_playbackState;
}

int MediaPlayer::position() const
{
    return m_position;
}

int MediaPlayer::duration() const
{
    MediaDataSource* dataSource = MediaPlayerDataController::instance()->dataForSource(source());
    if (dataSource) return dataSource->duration();
    return 0;
}

MediaPlayer::Error MediaPlayer::error() const
{
    return NoError;
}

QString MediaPlayer::errorString() const
{
    return QString();
}

void MediaPlayer::pause()
{
    if (m_playbackState == PlayingState) {
        m_playbackState = PausedState;
        Q_EMIT playbackStateChanged(m_playbackState);
        m_timer.stop();
    }
}

void MediaPlayer::play()
{
    if (m_playbackState != PlayingState) {
        m_playbackState = PlayingState;
        Q_EMIT playbackStateChanged(m_playbackState);

        m_timer.start();
    }
}

void MediaPlayer::stop()
{
    if (m_playbackState != StoppedState) {
        m_playbackState = StoppedState;
        Q_EMIT playbackStateChanged(m_playbackState);
        m_timer.stop();
        m_position = 0;
        Q_EMIT positionChanged(m_position);
    }
}

void MediaPlayer::seek(int position)
{
    if (status() != Loaded) return;
    int newPosition = qMin(qMax(0, position), duration());
    if (newPosition != m_position) {
        m_position = newPosition;
        Q_EMIT positionChanged(m_position);
    }
}

void MediaPlayer::timerEvent()
{
    if (m_position + m_timer.interval() < duration()) {
        m_position +=  m_timer.interval();
        Q_EMIT positionChanged(m_position);
    } else {
        pause();
    }
}

MediaPlayer::AudioRole MediaPlayer::audioRole() const
{
    return MediaPlayer::MusicRole;
}

void MediaPlayer::setAudioRole(MediaPlayer::AudioRole audioRole)
{
    Q_UNUSED(audioRole);
}

bool MediaPlayer::isSeekable() const
{
    MediaDataSource* dataSource = MediaPlayerDataController::instance()->dataForSource(source());
    if (dataSource) return dataSource->isSeekable();
    return true;
}

MediaPlayer::Availability MediaPlayer::availability() const
{
    MediaDataSource* dataSource = MediaPlayerDataController::instance()->dataForSource(source());
    if (dataSource) return dataSource->availability();
    return Available;
}

QObject *MediaPlayer::metaData() const
{
    return m_metaData;
}


MediaDataSource::MediaDataSource(QObject *parent)
    : QObject(parent)
    , m_seekable(true)
    , m_duration((qrand() % 20000) + 10000)
    , m_availability(MediaPlayer::Available)
{
}

MediaDataSource::~MediaDataSource()
{
    if (!m_source.isEmpty()) MediaPlayerDataController::instance()->unregisterDataSource(this);
}

void MediaDataSource::setSource(const QUrl &source)
{
    if (m_source != source) {
        if (!m_source.isEmpty()) MediaPlayerDataController::instance()->unregisterDataSource(this);

        m_source = source;

        if (!m_source.isEmpty()) MediaPlayerDataController::instance()->registerDataSource(this);
        Q_EMIT sourceChanged();
    }
}

void MediaDataSource::setSeekable(bool seekable)
{
    if (m_seekable != seekable) {
        m_seekable = seekable;
        Q_EMIT seekableChanged(m_seekable);
    }
}

void MediaDataSource::setDuration(int duration)
{
    if (m_duration != duration) {
        m_duration = duration;
        Q_EMIT durationChanged(m_duration);
    }
}

void MediaDataSource::setAvailability(MediaPlayer::Availability availability)
{
    if (m_availability != availability) {
        m_availability = availability;
        Q_EMIT availabilityChanged(m_availability);
    }
}

void MediaDataSource::setMetaData(const QVariant& metaData)
{
    if (m_metaData != metaData) {
        m_metaData = metaData;
        Q_EMIT metaDataChanged();
    }
}

MediaPlayerDataController *MediaPlayerDataController::instance()
{
    static MediaPlayerDataController* instance = nullptr;
    if (!instance) { instance = new MediaPlayerDataController(); }
    return instance;
}

void MediaPlayerDataController::registerDataSource(MediaDataSource *dataSource)
{
    m_dataSources[dataSource->source()] = dataSource;
    Q_EMIT sourceAdded(dataSource->source());
}

void MediaPlayerDataController::unregisterDataSource(MediaDataSource *dataSource)
{
    QList<QUrl> keys = m_dataSources.keys(dataSource);
    Q_FOREACH(const QUrl& key, keys) {
        Q_EMIT sourceAboutToBeRemoved(key);
        m_dataSources.remove(key);
    }
}

MediaDataSource *MediaPlayerDataController::dataForSource(const QUrl &source)
{
    if (!m_dataSources.contains(source)) {
        static MediaDataSource defaultSource;
        return &defaultSource;
    }
    return m_dataSources[source];
}

#include "mediaplayer.moc"
