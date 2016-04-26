/*
 * Copyright 2014,2016 Canonical Ltd.
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

    property var surface

    Column {
        id: column
        Layout.fillWidth: true
        visible: repeater.count
        spacing: units.gu(1)

        Repeater {
            id: repeater
            model: root.surface ? root.surface.promptSurfaceList : null
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
                        item.surface = model.surface;
                    }
                }
            }
        }
    }

    ColumnLayout {
        Layout.fillWidth: true
        spacing: units.gu(1)

        RowLayout {
            id: buttonLayout

            Button {
                enabled: root.surface
                activeFocusOnPress: false
                text: "Remove"
                onClicked: { root.surface.close(); }
            }

            Button {
                enabled: root.surface !== null
                activeFocusOnPress: false
                text: "Add Prompt Surface"
                onClicked: { root.surface.createPromptSurface(); }
            }
        }
    }
}
