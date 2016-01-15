/*
 * Copyright 2016 Canonical Ltd.
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
import "../../../qml/Components/ListItems" as ListItems

Column {
    id: socialAttributes
    height: divider.height + row.height + spacing
    spacing: units.gu(0.5)

    property alias model: repeater.model
    property color color: theme.palette.normal.baseText
    property real fontScale: 1.0

    signal clicked(var result)

    ListItems.ThinDivider {
        id: divider
        anchors { left: parent.left; right: parent.right; }
    }

    Row {
        id: row
        height: units.gu(2)
        spacing: units.gu(1)
        anchors {
            left: parent.left
            right: parent.right
            leftMargin: units.gu(1)
            rightMargin: units.gu(1)
        }

        Repeater {
            id: repeater
            delegate: Row {
                id: delegate
                objectName: "delegate" + index
                spacing: units.gu(0.5)
                height: units.gu(2)
                AbstractButton {
                    height: units.gu(2)
                    width: icon.width
                    Icon {
                        id: icon
                        objectName: "icon"

                        property url urlIcon: "icon" in modelData && modelData["icon"] || ""
                        property url urlTemporaryIcon: "temporaryIcon" in modelData && modelData["temporaryIcon"] || ""

                        height: units.gu(2)
                        // FIXME Workaround for bug https://bugs.launchpad.net/ubuntu/+source/ubuntu-ui-toolkit/+bug/1421293
                        width: implicitWidth > 0 && implicitHeight > 0 ? (implicitWidth / implicitHeight * height) : implicitWidth
                        source: urlIcon
                        color: socialAttributes.color

                        onUrlIconChanged: if (urlIcon) source = urlIcon
                    }

                    onClicked: socialAttributes.clicked(modelData["id"]);
                    onPressedChanged: if (pressed && icon.urlTemporaryIcon != "") icon.source = icon.urlTemporaryIcon
                }
                Label {
                    id: label
                    anchors.verticalCenter: parent.verticalCenter
                    text: "label" in modelData && modelData["label"] || "";
                    elide: Text.ElideRight
                    maximumLineCount: 1
                    fontSize: "small"
                    font.pixelSize: Math.round(FontUtils.sizeToPixels(fontSize) * fontScale)
                    color: socialAttributes.color
                }
            }
        }
    }
}
