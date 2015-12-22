/*
 * Copyright (C) 2012,2013 Canonical, Ltd.
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
 * Authors: Michael Zanetti <michael.zanetti@canonical.com>
 */

#include "plugin.h"
#include "audio.h"
#include "declarativeplaylist.h"

#include <QtQml/qqml.h>

void MockQtMultimediaPlugin::registerTypes(const char *uri)
{
    Q_ASSERT(uri == QLatin1String("QtMultimedia"));
    qmlRegisterType<Audio>(uri, 5, 0, "Audio");
    qmlRegisterType<Audio>(uri, 5, 0, "MediaPlayer");
    qmlRegisterType<DeclarativePlaylist>(uri, 5, 6, "Playlist");
}
