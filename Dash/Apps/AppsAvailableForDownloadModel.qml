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
import "../../Applications"

ListModel {
    ListElement {
        uri: "application://evernote.desktop"
        icon: "../../graphics/applicationIcons/evernote.png"
        category: 0
        mimetype: "application/x-desktop"
        title: "Evernote"
        comment: ""
        dndUri: "file:///usr/share/applications/evernote.desktop"
        metadata: ""
    }
    ListElement {
        uri: "application://map.desktop"
        icon: "../../graphics/applicationIcons/map.png"
        category: 0
        mimetype: "application/x-desktop"
        title: "Map"
        comment: ""
        dndUri: "file:///usr/share/applications/map.desktop"
        metadata: ""
    }
    ListElement {
        uri: "application://pinterest.desktop"
        icon: "../../graphics/applicationIcons/pinterest.png"
        category: 0
        mimetype: "application/x-desktop"
        title: "Pinterest"
        comment: ""
        dndUri: "file:///usr/share/applications/pinterest.desktop"
        metadata: ""
    }
    ListElement {
        uri: "application://soundcloud.desktop"
        icon: "../../graphics/applicationIcons/soundcloud.png"
        category: 0
        mimetype: "application/x-desktop"
        title: "Soundcloud"
        comment: ""
        dndUri: "file:///usr/share/applications/soundcloud.desktop"
        metadata: ""
    }
    ListElement {
        uri: "application://wikipedia.desktop"
        icon: "../../graphics/applicationIcons/wikipedia.png"
        category: 0
        mimetype: "application/x-desktop"
        title: "Wikipedia"
        comment: ""
        dndUri: "file:///usr/share/applications/wikipedia.desktop"
        metadata: ""
    }
    ListElement {
        uri: "application://youtube.desktop"
        icon: "../../graphics/applicationIcons/youtube.png"
        category: 0
        mimetype: "application/x-desktop"
        title: "Youtube"
        comment: ""
        dndUri: "file:///usr/share/applications/youtube.desktop"
        metadata: ""
    }
}
