/*
 * This file is part of the Ubuntu TV Media Scanner
 * Copyright (C) 2012-2013 Canonical Ltd.
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU Lesser General Public License version 3 as
 * published by the Free Software Foundation.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU Lesser General Public License for more details.
 *
 * You should have received a copy of the GNU Lesser General Public License
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.
 *
 * Authored by: Jussi Pakkanen <jussi.pakkanen@canonical.com>
 */

#ifndef MEDIAARTCACHE_H
#define MEDIAARTCACHE_H

#include<string>

/*
 * A class to store thumbnails for files according to
 * https://wiki.gnome.org/MediaArtStorageSpec
 *
 * As this class deals mostly with the filesystem, all
 * errors are reported with runtime_error exceptions.
 */


class MediaArtCache {
private:
    std::string root_dir;

    std::string compute_base_name(const std::string &artist, const std::string &album) const;
    std::string get_full_filename(const std::string &artist, const std::string & album) const;

public:
    static const unsigned int MAX_SIZE = 200;

    MediaArtCache();
    bool has_art(const std::string &artist, const std::string &album) const;
    void add_art(const std::string &artist, const std::string &album,
            char *data, unsigned int datalen);
    std::string get_art_file(const std::string &artist, const std::string &album) const;
    void clear() const;
    void prune();
    std::string get_cache_dir() const { return root_dir; }
};

#endif
