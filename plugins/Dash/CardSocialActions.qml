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

Column {
    id: socialActions
    spacing: units.gu(0.5)

    property alias model: repeater.model
    property color color: theme.palette.normal.baseText

    signal clicked(var actionId)

    Rectangle {
        id: divider
        visible: repeater.count > 0
        anchors {
            left: parent.left;
            right: parent.right;
            leftMargin:units.dp(1);
            rightMargin: units.dp(1);
        }
        color: Qt.darker(theme.palette.normal.background, 1.12)
        height: visible ? units.dp(1) : 0
    }

    Row {
        id: row
        anchors {
            left: parent.left
            right: parent.right
            leftMargin: units.gu(1)
            rightMargin: units.gu(1)
        }
        spacing: units.gu(2)
        readonly property int visibleItems: {
            if (width <= units.gu(12)) // small card
                return 2;
            else if (width <= units.gu(21)) // medium card
                return 3;
            else // large or horizontal card
                return 4;
        }

        Repeater {
            id: repeater
            delegate: Loader {
                height: units.gu(2)
                active: index < row.visibleItems
                sourceComponent: AbstractButton {
                    objectName: "delegate" + index
                    height: units.gu(2)
                    width: icon.width
                    Icon {
                        id: icon
                        objectName: "icon"

                        readonly property url urlIcon: modelData && modelData["icon"] || ""
                        readonly property url urlTemporaryIcon: "temporaryIcon" in modelData && modelData["temporaryIcon"] || ""

                        height: units.gu(2)
                        // FIXME Workaround for bug https://bugs.launchpad.net/ubuntu/+source/ubuntu-ui-toolkit/+bug/1421293
                        width: implicitWidth > 0 && implicitHeight > 0 ? (implicitWidth / implicitHeight * height) : implicitWidth
                        source: urlIcon
                        color: socialActions.color

                        onUrlIconChanged: {
                            if (urlIcon) source = urlIcon
                        }
                    }

                    onClicked: socialActions.clicked(modelData["id"]);
                    onPressedChanged: if (pressed && icon.urlTemporaryIcon != "") icon.source = icon.urlTemporaryIcon
                }
            }
        }
    }
}
