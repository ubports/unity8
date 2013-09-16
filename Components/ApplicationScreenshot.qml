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
import Ubuntu.Components 0.1
import Unity.Application 0.1

Item {
    id: applicationScreenshot

    property var application: null
    property bool withBackground: false
    property bool ready: applicationImage.ready || withBackground

    function setApplication(application) {
        applicationScreenshot.application = application
    }

    function clearApplication() {
        applicationScreenshot.withBackground = false;
        applicationScreenshot.application = null
        applicationScreenshot.scheduleUpdate();
    }

    function scheduleUpdate() {
        applicationImage.scheduleUpdate()
    }

    function updateFromCache() {
        applicationImage.updateFromCache()
    }

    Rectangle {
        id: background
        anchors.fill: parent
        color: "white" // FIXME should use normal background color of Suru theme
        visible: applicationScreenshot.withBackground
    }

    ApplicationImage {
        id: applicationImage
        objectName: "screenshot image"
        width: applicationScreenshot.application ? parent.width : 0
        height: applicationScreenshot.application ? parent.height : 0
        visible: applicationScreenshot.application != null && ready
        source: ApplicationManager.findApplication((application) ? application.appId : "")
    }
}
