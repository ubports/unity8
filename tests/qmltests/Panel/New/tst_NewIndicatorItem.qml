/*
 * Copyright 2013 Canonical Ltd.
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
import QtTest 1.0
import ".."
import "../../../../qml/Panel/New"
import Ubuntu.Components 0.1
import Unity.Test 0.1 as UT

Rectangle {
    width: units.gu(80)
    height: units.gu(30)
    color: "white"

    Rectangle {
        id: itemArea
        color: "blue"
        anchors {
            top: parent.top
            bottom: parent.bottom
        }
        width: units.gu(30)


        Rectangle {
            color: "black"
            anchors.fill: indicatorItem
        }

        IndicatorItem {
            id: indicatorItem
            height: expanded ? units.gu(7) : units.gu(3)
            anchors.centerIn: parent

            rootActionState {
                title: "Test Title"
                leftLabel : leftLabel.text
                rightLabel : rightLabel.text
                icons : {
                    var icons = [];
                    var i = 0;
                    if (iconEnabled.checked) {
                        for (i = 0; i < String(iconCount.text); i++) {
                            icons.append("image://theme/audio-volume-high");
                        }
                    }
                    return icons;
                }
            }

            Behavior on height {NumberAnimation{duration: UbuntuAnimation.SnapDuration; easing: UbuntuAnimation.StandardEasing}}
        }
    }

    ColumnLayout {
        anchors {
            top: parent.top
            bottom: button.top
            left: itemArea.right
            right: parent.right
        }

        RowLayout {
            CheckBox { id: iconEnabled; checked: true }
            Label { text: "icons    Count:" }
            TextField { id: iconCount; text: "1"; enabled: iconEnabled.checked }
        }

        RowLayout {
            Label { text: "Left Label:" }
            TextField { id: leftLabel; text: "Left"}
        }

        RowLayout {
            Label { text: "Right Label:" }
            TextField { id: rightLabel; text: "Right"}
        }
    }

    Button {
        id: button
        anchors {
            left: parent.left
            right: parent.right
            bottom: parent.bottom
        }
        text: indicatorItem.expanded ? "Collapse" : "Expand"
        onClicked: indicatorItem.expanded = !indicatorItem.expanded
    }

    UT.UnityTestCase {
        name: "IndicatorItem"
    }
}
