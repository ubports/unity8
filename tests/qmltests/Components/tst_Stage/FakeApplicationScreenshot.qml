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

Item {
    property var application
    property bool withBackground: true
    property bool ready: application != undefined

    function setApplication(app) {
        application = app
    }

    function clearApplication() {
        setApplication(undefined)
    }

    function scheduleUpdate() {}

    function updateFromCache() {}

    Rectangle {
        id: rect
        anchors.fill: parent
        Text {id:text}
    }

    onApplicationChanged: {
        if (application) {
            rect.color = application.color
            text.text = application.desktopFile + " screenshot"
            rect.visible = true
        } else {
            rect.color = "white"
            text.text = "<NULL> screenshot"
            rect.visible = false
        }
    }
}
