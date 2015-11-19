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

import QtQuick 2.4
import QtQuick.Layouts 1.1
import Ubuntu.Components 1.3
import Unity.Application 0.1

ColumnLayout {
    id: root

    property var session
    property var childSessions: session ? session.childSessions : 0
    property bool removable: false
    property alias surfaceCheckbox: _surfaceCheckbox

    property var screenshotIds: [ "gallery", "map", "facebook", "camera", "browser", "music", "twitter"]

    onSessionChanged: {
        if (!session) surfaceCheckbox.checked = false;
    }

    Column {
        id: column
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
                    left: column.left
                    right: column.right
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

    ColumnLayout {
        Layout.fillWidth: true
        spacing: units.gu(1)

        RowLayout {
            Layout.fillWidth: true

            CheckBox {
                id: _surfaceCheckbox;
                checked: false;
                activeFocusOnPress: false
                enabled: root.session
                onCheckedChanged: {
                    if (checked) {
                        root.session.createSurface();
                    } else if (root.session && root.session.surface) {
                        ApplicationTest.removeSurface(root.session.surface);
                    }
                }

                Connections {
                    target: root.session ? root.session : null
                    onSurfaceChanged: {
                        surfaceCheckbox.checked = root.session.surface !== null
                    }
                }
            }

            Label {
                text: "Surface"
                anchors.verticalCenter: parent.verticalCenter
            }
        }

        RowLayout {
            id: buttonLayout

            Button {
                enabled: root.session
                activeFocusOnPress: false
                text: removable ? "Remove" : "Release"
                onClicked: {
                    if (removable) {
                        // release the surface first. simulates mir app closing
                        if (root.session.surface) ApplicationTest.removeSurface(root.session.surface);
                        ApplicationTest.removeSession(root.session);
                    } else {
                        root.session.release();
                    }
                }
            }

            Button {
                enabled: root.session !== null
                activeFocusOnPress: false
                text: "Add Child"
                onClicked: {
                    var screenshot = Math.round(Math.random()*100 % (screenshotIds.length-1));
                    var session = ApplicationTest.addChildSession(root.session, root.screenshotIds[screenshot]);
                }
            }
        }
    }
}
