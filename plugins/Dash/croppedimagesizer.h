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

#ifndef CROPPEDIMAGESIZER_H
#define CROPPEDIMAGESIZER_H

#include <QImageReader>
#include <QObject>
#include <QSize>
#include <QUrl>

class QNetworkReply;

class CroppedImageSizer : public QObject
{
    Q_OBJECT

    Q_PROPERTY(QUrl source READ source WRITE setSource NOTIFY inputParamsChanged)
    Q_PROPERTY(qreal width READ width WRITE setWidth NOTIFY inputParamsChanged)
    Q_PROPERTY(qreal height READ height WRITE setHeight NOTIFY inputParamsChanged)
    Q_PROPERTY(QSize sourceSize READ sourceSize NOTIFY sourceSizeChanged)

public:
    CroppedImageSizer();
    ~CroppedImageSizer();

    QUrl source() const;
    void setSource(const QUrl &source);

    qreal width() const;
    void setWidth(qreal width);

    qreal height() const;
    void setHeight(qreal height);

    QSize sourceSize() const;

Q_SIGNALS:
    void inputParamsChanged();
    void sourceSizeChanged();

private Q_SLOT:
    void calculateSourceSize();
    void requestFinished();

private:
    QUrl m_source;
    qreal m_width;
    qreal m_height;
    QSize m_sourceSize;
    QNetworkReply *m_reply = nullptr;
};

#endif
