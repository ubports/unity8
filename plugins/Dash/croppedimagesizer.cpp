/*
 * Copyright (C) 2014 Canonical, Ltd.
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

#include "croppedimagesizer.h"

#include <QDebug>
#include <QNetworkReply>
#include <QNetworkRequest>
#include <QQmlEngine>
#include <QQuickItem>
#include <QQuickView>

CroppedImageSizer::CroppedImageSizer()
{
    connect(this, &CroppedImageSizer::inputParamsChanged, this, &CroppedImageSizer::calculateSourceSize);
}

CroppedImageSizer::~CroppedImageSizer()
{
    if (m_reply) {
        m_reply->deleteLater();
    }
}

QUrl CroppedImageSizer::source() const
{
    return m_source;
}

void CroppedImageSizer::setSource(const QUrl &source)
{
    if (source != m_source) {
        m_source = source;
        Q_EMIT inputParamsChanged();
    }
}

qreal CroppedImageSizer::width() const
{
    return m_width;
}

void CroppedImageSizer::setWidth(qreal width)
{
    if (width != m_width) {
        m_width = width;
        Q_EMIT inputParamsChanged();
    }
}

qreal CroppedImageSizer::height() const
{
    return m_height;
}

void CroppedImageSizer::setHeight(qreal height)
{
    if (height != m_height) {
        m_height = height;
        Q_EMIT inputParamsChanged();
    }
}

QSize CroppedImageSizer::sourceSize() const
{
    return m_sourceSize;
}

void CroppedImageSizer::calculateSourceSize()
{
    if (m_source.isValid() && m_width > 0 && m_height > 0 && qmlEngine(this) && qmlEngine(this)->networkAccessManager()) {
        if (m_reply) {
            m_reply->abort();
            m_reply->deleteLater();
        }
        QNetworkRequest request(m_source);
        m_reply = qmlEngine(this)->networkAccessManager()->get(request);
        connect(m_reply, &QNetworkReply::finished, this, &CroppedImageSizer::requestFinished);
    }
}

void CroppedImageSizer::requestFinished()
{
    QImageReader m_reader(m_reply);
    const QSize imageSize = m_reader.size();
    if (imageSize.isValid()) {
        if (m_height > 0 && imageSize.height() > 0) {
            const qreal ar = m_width / m_height;
            const qreal ssar = imageSize.width() / imageSize.height();
            if (ar > ssar) {
                m_sourceSize = QSize(m_width, 0);
            } else {
                m_sourceSize = QSize(0, m_height);
            }
        }
    } else {
        qWarning() << "Could not find size of" << m_source;
        m_sourceSize = QSize(0, 0);
    }
    sourceSizeChanged();

    m_reply->deleteLater();
    m_reply = nullptr;
}
