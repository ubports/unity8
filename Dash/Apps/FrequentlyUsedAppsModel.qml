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

ListModel {
    ListElement {
        uri: "application:///usr/share/applications/camera-app.desktop"
        icon: "../../graphics/applicationIcons/camera.png"
        category: 0
        mimetype: "application/x-desktop"
        title: "Camera"
        comment: ""
        dndUri: "file:///usr/share/applications/camera-app.desktop"
        metadata: ""
    }
    ListElement {
        uri: "application:///usr/share/applications/phone-app.desktop"
        icon: "../../graphics/applicationIcons/phone-app.png"
        category: 0
        mimetype: "application/x-desktop"
        title: "Phone"
        comment: ""
        dndUri: "file:///usr/share/applications/phone-app.desktop"
        metadata: ""
    }
    ListElement {
        uri: "application:///usr/share/applications/gallery-app.desktop"
        icon: "../../graphics/applicationIcons/gallery.png"
        category: 0
        mimetype: "application/x-desktop"
        title: "Gallery"
        comment: ""
        dndUri: "file:///usr/share/applications/gallery.desktop"
        metadata: ""
    }
    ListElement {
        uri: "application:///usr/share/applications/facebook-webapp.desktop"
        icon: "../../graphics/applicationIcons/facebook.png"
        category: 0
        mimetype: "application/x-desktop"
        title: "Facebook"
        comment: ""
        dndUri: "file:///usr/share/applications/facebook-webapp.desktop"
        metadata: ""
    }
    ListElement {
        uri: "application:///usr/share/applications/webbrowser-app.desktop"
        icon: "../../graphics/applicationIcons/browser.png"
        category: 0
        mimetype: "application/x-desktop"
        title: "Browser"
        comment: ""
        dndUri: "file:///usr/share/applications/webbrowser-app.desktop"
        metadata: ""
    }
    ListElement {
        uri: "application:///usr/share/applications/gmail-webapp.desktop"
        icon: "../../graphics/applicationIcons/gmail.png"
        category: 0
        mimetype: "application/x-desktop"
        title: "GMail"
        comment: ""
        dndUri: "file:///usr/share/applications/gmail-webapp.desktop"
        metadata: ""
    }
}
