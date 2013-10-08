/*
 * Copyright 2013 Canonical Ltd.
 *
 * This program is free software; you can redistribute it and/or modify
 * it under the terms of the GNU Lesser General Public License as published by
 * the Free Software Foundation; version 3.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
 * GNU Lesser General Public License for more details.
 *
 * You should have received a copy of the GNU Lesser General Public License
 * along with this program. If not, see <http://www.gnu.org/licenses/>.
 *
 * Authors: Jussi Pakkanen <jussi.pakkanen@canonical.com>
*/

#ifndef ALBUMART_PROVIDER_H_
#define ALBUMART_PROVIDER_H_

#include <string>
#include <stdexcept>
#include <QQuickImageProvider>
#include <gio/gio.h>

#include "mediaartcache.h"

struct albuminfo {
    std::string artist;
    std::string album;
};

class AlbumArtProvider : public QQuickImageProvider
{
public:
    AlbumArtProvider();
    ~AlbumArtProvider();
    QImage requestImage(const QString &id, QSize *size, const QSize &requestedSize);

    std::string get_image(const std::string &artist, const std::string &album);

    const static std::string DEFAULT_ALBUM_ART;
private:
    MediaArtCache cache;
    GSettings *m_settings;

    void fix_format(const std::string &fname);

    std::string get_lastfm_url(const albuminfo &ai);

    bool download_and_store(const std::string &image_url, const std::string &output_file);
};

#endif
