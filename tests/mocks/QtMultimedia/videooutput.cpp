/*
 * Copyright (C) 2016 Canonical, Ltd.
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

#include "videooutput.h"
#include "mediaplayer.h"

#include <paths.h>

#include <QQuickView>
#include <QQmlComponent>
#include <QGuiApplication>
#include <QQmlProperty>
#include <QQmlEngine>

VideoOutput::VideoOutput(QQuickItem *parent)
    : QQuickItem(parent)
    , m_source(nullptr)
    , m_qmlContentComponent(nullptr)
    , m_qmlItem(nullptr)
{
}

void VideoOutput::setSource(QObject *source)
{
    if (m_source != source) {
        if (m_source) disconnect(m_source, 0, this, 0);

        m_source = source;
        Q_EMIT sourceChanged();

        MediaPlayer* mediaPlayer = qobject_cast<MediaPlayer*>(source);
        if (mediaPlayer) {
            connect(mediaPlayer, &MediaPlayer::positionChanged, this, &VideoOutput::updateProperties);
            connect(mediaPlayer, &MediaPlayer::playbackStateChanged, this, &VideoOutput::updateProperties);
            connect(mediaPlayer->metaData(), SIGNAL(metaDataChanged()), this, SLOT(updateProperties()));
        }
    }
}

void VideoOutput::itemChange(QQuickItem::ItemChange change, const QQuickItem::ItemChangeData &value)
{
    if (change == QQuickItem::ItemSceneChange && !m_qmlContentComponent) {
        QWindowList list = QGuiApplication::topLevelWindows();
        if (list.isEmpty()) return;

        // The assumptions I make here really should hold.
        QQuickView *quickView =
            qobject_cast<QQuickView*>(list[0]);

        m_qmlContentComponent = new QQmlComponent(quickView->engine(),
                                                  QString("%1/QtMultimedia/VideoSurface.qml").arg(mockPluginsDir()));

        switch (m_qmlContentComponent->status()) {
            case QQmlComponent::Ready:
                createQmlContentItem();
                break;
            case QQmlComponent::Loading:
                connect(m_qmlContentComponent, &QQmlComponent::statusChanged,
                        this, &VideoOutput::onComponentStatusChanged);
                break;
            case QQmlComponent::Error:
                printComponentErrors();
                qFatal("VideoOutput: failed to create content component.");
                break;
            default:
                qFatal("VideoOutput: Unhandled component status");
        }
    }
    QQuickItem::itemChange(change, value);
}

void VideoOutput::printComponentErrors()
{
    QList<QQmlError> errors = m_qmlContentComponent->errors();
    for (int i = 0; i < errors.count(); ++i) {
        qDebug() << errors[i];
    }
}

void VideoOutput::onComponentStatusChanged(QQmlComponent::Status status)
{
    if (status == QQmlComponent::Ready) {
        createQmlContentItem();
    }
}

void VideoOutput::createQmlContentItem()
{
    m_qmlItem = qobject_cast<QQuickItem*>(m_qmlContentComponent->create());
    m_qmlItem->setParentItem(this);

    updateProperties();
}

void VideoOutput:: updateProperties()
{
    if (!m_qmlItem) return;

    MediaPlayer* mediaPlayer = qobject_cast<MediaPlayer*>(m_source);
    if (!mediaPlayer) return;

    QQmlProperty playbackStateProperty(m_qmlItem, "playbackState");
    playbackStateProperty.write(QVariant::fromValue<int>(mediaPlayer->playbackState()));

    QQmlProperty positionProperty(m_qmlItem, "position");
    positionProperty.write(QVariant::fromValue(mediaPlayer->position()));

    QQmlProperty propResSource(mediaPlayer->metaData(), "resolution");
    QQmlProperty propResDest(m_qmlItem, "resolution");

    if (propResSource.isValid() && propResDest.isValid()) {
        propResDest.write(propResSource.read());
    }
}
