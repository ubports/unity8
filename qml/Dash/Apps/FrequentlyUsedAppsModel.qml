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
        uri: "application://dialer-app.desktop"
        icon: "../../graphics/applicationIcons/phone-app.png"
        category: 0
        mimetype: "application/x-desktop"
        title: "Dialer"
        comment: ""
        dndUri: "file:///usr/share/applications/dialer-app.desktop"
        metadata: "subscope:applications.scope/applications-non-click.scope"
    }
    ListElement {
        uri: "application://messaging-app.desktop"
        icon: "../../graphics/applicationIcons/messages-app.png"
        category: 0
        mimetype: "application/x-desktop"
        title: "Messaging"
        comment: ""
        dndUri: "file:///usr/share/applications/messaging-app.desktop"
        metadata: "subscope:applications.scope/applications-non-click.scope"
    }
    ListElement {
        uri: "application://address-book-app.desktop"
        icon: "../../graphics/applicationIcons/contacts-app.png"
        category: 0
        mimetype: "application/x-desktop"
        title: "Contacts"
        comment: ""
        dndUri: "file:///usr/share/applications/address-book-app.desktop"
        metadata: "subscope:applications.scope/applications-non-click.scope"
    }
    ListElement {
        uri: "appid://com.ubuntu.camera/camera/current-user-version"
        icon: "../../graphics/applicationIcons/camera.png"
        category: 0
        mimetype: "application/x-desktop"
        title: "Camera"
        comment: ""
        dndUri: "appid://com.ubuntu.camera/camera/current-user-version"
        metadata: "subscope:applications.scope/applications-click.scope?app_id=com.ubuntu.camera"
    }
    ListElement {
        uri: "appid://com.ubuntu.gallery/gallery/current-user-version"
        icon: "../../graphics/applicationIcons/gallery.png"
        category: 0
        mimetype: "application/x-desktop"
        title: "Gallery"
        comment: ""
        dndUri: "appid://com.ubuntu.gallery/gallery/current-user-version"
        metadata: "subscope:applications.scope/applications-click.scope?app_id=com.ubuntu.gallery"
    }
    ListElement {
        uri: "appid://com.ubuntu.developer.webapps.webapp-facebook/webapp-facebook/current-user-version"
        icon: "../../graphics/applicationIcons/facebook.png"
        category: 0
        mimetype: "application/x-desktop"
        title: "Facebook"
        comment: ""
        dndUri: "appid://com.ubuntu.developer.webapps.webapp-facebook/webapp-facebook/current-user-version"
        metadata: "subscope:applications.scope/applications-click.scope?app_id=com.ubuntu.developer.webapps.webapp-facebook"
    }
    ListElement {
        uri: "application://webbrowser-app.desktop"
        icon: "../../graphics/applicationIcons/browser.png"
        category: 0
        mimetype: "application/x-desktop"
        title: "Browser"
        comment: ""
        dndUri: "file:///usr/share/applications/webbrowser-app.desktop"
        metadata: "subscope:applications.scope/applications-non-click.scope"
    }
    ListElement {
        uri: "appid://com.ubuntu.developer.webapps.webapp-gmail/webapp-gmail/current-user-version"
        icon: "../../graphics/applicationIcons/gmail.png"
        category: 0
        mimetype: "application/x-desktop"
        title: "GMail"
        comment: ""
        dndUri: "appid://com.ubuntu.developer.webapps.webapp-gmail/webapp-gmail/current-user-version"
        metadata: "subscope:applications.scope/applications-click.scope?app_id=com.ubuntu.developer.webapps.webapp-gmail"
    }
    ListElement {
        uri: "application://ubuntu-system-settings.desktop"
        icon: "../../graphics/applicationIcons/system-settings.png"
        category: 0
        mimetype: "application/x-desktop"
        title: "System Settings"
        comment: ""
        dndUri: "file:///usr/share/applications/ubuntu-system-settings.desktop"
        metadata: "subscope:applications.scope/applications-non-click.scope"
    }
}
