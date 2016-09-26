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

#include <QDateTime>
#include <QDebug>
#include <QDir>
#include <QUrl>
#include <QUrlQuery>

#include "ImageCache.h"

ImageCache::ImageCache()
  : QQuickImageProvider(QQmlImageProviderBase::Image,
                        QQmlImageProviderBase::ForceAsynchronousImageLoading)
{
}

QString ImageCache::imageCacheRoot()
{
    QString xdgCache(qgetenv("XDG_CACHE_HOME"));
    if (xdgCache.isEmpty()) {
        xdgCache = QDir::homePath() + QStringLiteral("/.cache");
    }

    return QDir::cleanPath(xdgCache) + QStringLiteral("/unity8/imagecache");
}

QFileInfo ImageCache::imagePath(const QUrl &image)
{
    QUrlQuery query(image);

    auto name = query.queryItemValue(QStringLiteral("name"));
    if (name.isEmpty()) {
        name = QStringLiteral("/paths") + image.toLocalFile();
    } else {
        name = QStringLiteral("/names/") + name;
    }

    return QFileInfo(imageCacheRoot() + name);
}

bool ImageCache::needsUpdate(const QUrl &image, const QFileInfo &cachePath, const QSize &imageSize, const QSize &requestedSize, QSize &finalSize)
{
    if (!cachePath.exists())
        return true;

    QFileInfo imageInfo(image.toLocalFile());
    if (imageInfo.lastModified() > cachePath.lastModified())
        return true;

    QSize cacheSize(QImageReader(cachePath.filePath()).size());
    finalSize = calculateSize(imageSize, requestedSize);
    if (finalSize.isValid() && cacheSize != finalSize)
        return true;

    return false;
}

QSize ImageCache::calculateSize(const QSize &imageSize, const QSize &requestedSize)
{
    QSize finalSize(requestedSize);

    if (finalSize.width() == 0) {
        finalSize.setWidth(imageSize.width() * (((double)finalSize.height()) / imageSize.height()));
    } else if (finalSize.height() == 0) {
        finalSize.setHeight(imageSize.height() * (((double)finalSize.width()) / imageSize.width()));
    }

    return finalSize;
}

QImage ImageCache::loadAndCacheImage(QImageReader &reader, const QFileInfo &cachePath, const QSize &finalSize)
{
    reader.setQuality(100);
    reader.setScaledSize(finalSize);
    auto format = reader.format(); // can't get this after reading

    QImage loadedImage(reader.read());
    if (loadedImage.isNull()) {
        qWarning() << "ImageCache could not read image" << reader.fileName() << ":" << reader.errorString();
        return QImage();
    }

    cachePath.dir().mkpath(QStringLiteral("."));
    loadedImage.save(cachePath.filePath(), format, 100);

    return loadedImage;
}

QImage ImageCache::requestImage(const QString &id, QSize *size, const QSize &requestedSize)
{
    QUrl image(id);
    QImageReader imageReader(image.toLocalFile());
    QSize imageSize(imageReader.size());
    QImage result;

    // Early exit here, with no sourceSize, scaled-up sourceSize, or bad source image
    if ((requestedSize.width() <= 0 && requestedSize.height() <= 0) ||
        imageSize.isEmpty() ||
        requestedSize.height() >= imageSize.height() ||
        requestedSize.width() >= imageSize.width()) {
        // We're only interested in scaling down, not up.
        result = imageReader.read();
        *size = result.size();
        return result;
    }

    auto cachePath = imagePath(image);
    QSize finalSize;

    if (needsUpdate(image, cachePath, imageSize, requestedSize, finalSize)) {
        if (finalSize.isEmpty()) {
            finalSize = calculateSize(imageSize, requestedSize);
        }
        result = loadAndCacheImage(imageReader, cachePath, finalSize);
    } else {
        result = QImage(cachePath.filePath());
    }

    *size = result.size();
    return result;
}
