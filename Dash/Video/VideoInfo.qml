/*
 * Copyright (C) 2013 Canonical, Ltd.
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

import QtQuick 2.0
import QtQuick.XmlListModel 2.0

Item {
    id: info
    property string source

    property bool ready: nfo.status == XmlListModel.Ready || nfoTV.status == XmlListModel.Ready
    property bool isMovie: true
    property variant video: null
    property variant tvShow: null

    function getActors() {
        var c = []
        if (video.actor1) c.push(video.actor1)
        if (video.actor2) c.push(video.actor2)
        if (video.actor3) c.push(video.actor3)
        return c
    }

    onSourceChanged: isMovie = true

    XmlListModel {
        id: nfo
        source: info.source
        query: (isMovie) ? "/movie" : "/episodedetails"

        XmlRole { name: "title"; query: "title/string()" }
        XmlRole { name: "year"; query: "year/number()" }
        XmlRole { name: "runtime"; query: "runtime/number()" }
        XmlRole { name: "rating"; query: "rating/number()" }
        XmlRole { name: "plot"; query: "plot/string()" }
        XmlRole { name: "director"; query: "director[1]/string()" }
        XmlRole { name: "actor1"; query: "actor[1]/name/string()" }
        XmlRole { name: "actor2"; query: "actor[2]/name/string()" }
        XmlRole { name: "actor3"; query: "actor[3]/name/string()" }
        XmlRole { name: "author"; query: "author[1]/string()" }
        XmlRole { name: "season"; query: "season/number()" }
        XmlRole { name: "episode"; query: "episode/number()" }

        XmlRole { name: "rentPrice"; query: "rent_price/string()" }
        XmlRole { name: "buyPrice"; query: "buy_price/string()" }
        XmlRole { name: "expires"; query: "expires/string()" }

        onStatusChanged: if (status == XmlListModel.Ready) {
                             if (count > 0) info.video = nfo.get(0)
                             else info.isMovie = false
                         } else if (status == XmlListModel.Error) info.isMovie = false
    }

    XmlListModel {
        id: nfoTV
        source: (nfo.isMovie) ? "" : info.source.substring(0, info.source.lastIndexOf("/") + 1) + "tvshow.nfo"
        query: "/tvshow"

        XmlRole { name: "title"; query: "title/string()" }

        onStatusChanged: if (status == XmlListModel.Ready) {
                             if (count > 0) info.tvShow = nfoTV.get(0)
                         } else if (status == XmlListModel.Error) {
                             // Search for tvshow.nfo in the directory above this one to cater
                             // for directory layout Show/Season
                             var path = info.source.split("/")
                             path.splice(-2, 2, "tvshow.nfo")
                             source = path.join("/")
                         }
    }
}
