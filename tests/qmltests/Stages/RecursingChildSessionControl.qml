/*
 * Copyright 2014 Canonical Ltd.
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

import QtQuick 2.1
import QtQuick.Layouts 1.1
import Ubuntu.Components 0.1
import Unity.Application 0.1

ColumnLayout {
    id: root

    property var session
    property var childSessions: session ? session.childSessions : 0
    property bool removable: false

    property var screenshotIds: [ "gallery", "map", "facebook", "camera", "browser", "music", "twitter"]

    Column {
        Layout.fillWidth: true
        visible: repeater.count
        spacing: units.gu(1)

        Repeater {
            id: repeater
            model: root.childSessions
            delegate: Rectangle {
                border {
                    color: "black"
                    width: 1
                }
                anchors {
                    left: parent.left
                    right: parent.right
                    leftMargin: units.gu(1)
                    rightMargin: units.gu(1)
                }
                height: loader.height

                Rectangle {
                    anchors.fill: parent
                    color: Qt.rgba(Math.random(), Math.random(), Math.random(), 0.4 )
                }

                Loader {
                    id: loader
                    visible: status == Loader.Ready
                    source: Qt.resolvedUrl("RecursingChildSessionControl.qml")

                    anchors {
                        left: parent.left
                        right: parent.right
                    }

                    onLoaded: {
                        item.session = modelData;
                        item.removable = true;
                    }
                }
            }
        }
    }

    Item {
        Layout.fillWidth: true
        Layout.preferredHeight: buttonLayout.height + units.gu(1)

        RowLayout {
            id: buttonLayout
            anchors {
                top: parent.top; topMargin: units.gu(0.5)
                left: parent.left; leftMargin: units.gu(1)
            }

            Button {
                enabled: root.session
                text: removable ? "Remove" : "Release"
                onClicked: {
                    if (removable) root.session.removed();
                    else root.session.release();
                }
            }

            Button {
                enabled: root.session !== null
                text: "Add Child"
                onClicked: {
                    var screenshot = Math.round(Math.random() * screenshotIds.length);
                    console.log(screenshot)
                    var session = ApplicationTest.addChildSession(root.session, root.screenshotIds[screenshot]);
                }
            }
        }
    }
}
