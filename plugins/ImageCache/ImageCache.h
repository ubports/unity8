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

#pragma once

#include <QFileInfo>
#include <QImageReader>
#include <QQuickImageProvider>
#include <QSize>

/**
 * This class accepts an id formulated like a URL. So you'd use something like:
 *
 * Image {
 *    source: "image://unity8imagecache/file:///usr/share/..."
 * }
 *
 * Right now, we only support file:/// URLs. We do accept some flags though:
 *
 * ?name=NAME
 *   - This will use NAME as the cache lookup key instead of the provided URL.
 *
 * We don't do any cleaning of old cached files yet.  So you may want to always
 * provide a name to avoid leaving lots of files around.
 */

class ImageCache: public QQuickImageProvider
{
public:
    ImageCache();

    QImage requestImage(const QString &id, QSize *size, const QSize &requestedSize) override;

private:
    static QString imageCacheRoot();
    static QFileInfo imagePath(const QUrl &image);
    static bool needsUpdate(const QUrl &image, const QFileInfo &cachePath, const QSize &imageSize, const QSize &requestedSize, QSize &finalSize);
    static QSize calculateSize(const QSize &imageSize, const QSize &requestedSize);
    static QImage loadAndCacheImage(QImageReader &reader, const QFileInfo &cachePath, const QSize &finalSize);
};
