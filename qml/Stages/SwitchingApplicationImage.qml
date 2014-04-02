/*
 * Copyright 2014 Canonical Ltd.
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
 * Authors: Michael Zanetti <michael.zanetti@canonical.com>
*/

import QtQuick 2.0
import Ubuntu.Components 0.1

Rectangle {
    id: root
    implicitHeight: image.implicitHeight
    implicitWidth: image.implicitWidth
    color: "black"

    property var application

    signal switched()

    function switchTo(application) {
        if (root.application == application) {
            root.switched();
            return;
        }

        priv.newApplication = application
        root.visible = true;
        switchToAnimation.start()
    }

    QtObject {
        id: priv
        property var newApplication
    }

    Image {
        id: newImage
        anchors.bottom: parent.bottom
        width: root.width
        source: priv.newApplication ? priv.newApplication.screenshot : ""
    }

    Image {
        id: image
        visible: true
        source: root.application ? root.application.screenshot : ""
        width: root.width
        height: sourceSize.height
        anchors.bottom: parent.bottom

    }

    SequentialAnimation {
        id: switchToAnimation
        ParallelAnimation {
            UbuntuNumberAnimation { target: image; property: "x"; from: 0; to: root.width; duration: UbuntuAnimation.SlowDuration }
            UbuntuNumberAnimation { target: newImage; property: "scale"; from: 0.7; to: 1; duration: UbuntuAnimation.SlowDuration }
        }
        ScriptAction {
            script: {
                image.x = 0
                root.application = priv.newApplication
                root.visible = false;
                priv.newApplication = null
                root.switched();
            }
        }
    }
}
