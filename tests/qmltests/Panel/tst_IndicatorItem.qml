/*
 * Copyright 2013-2014 Canonical Ltd.
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
import QtTest 1.0
import Ubuntu.Components 1.3
import Unity.Test 0.1 as UT
import "../../../qml/Panel"

Rectangle {
    width: units.gu(80)
    height: units.gu(30)
    color: "white"

    RowLayout {
        anchors.fill: parent
        anchors.margins: units.gu(1)

        Rectangle {
            id: itemArea
            color: "blue"
            Layout.fillWidth: true
            Layout.fillHeight: true

            Rectangle {
                color: "black"
                anchors.fill: indicatorItem
            }

            IndicatorItem {
                id: indicatorItem
                height: expanded ? units.gu(7) : units.gu(3)
                anchors.centerIn: parent
                identifier: "indicator-test"

                rootActionState {
                    title: titleLabel.text
                    leftLabel : leftLabel.text
                    rightLabel : rightLabel.text
                    icons : {
                        var icons = [];
                        var i = 0;
                        if (iconEnabled.checked) {
                            for (i = 0; i < String(iconCount.text); i++) {
                                icons.push("image://theme/audio-volume-high");
                            }
                        }
                        return icons;
                    }
                }

                Behavior on height {
                    NumberAnimation {
                        id: heightAnimation
                        duration: UbuntuAnimation.SnapDuration; easing: UbuntuAnimation.StandardEasing
                    }
                }
            }
        }

        ColumnLayout {
            Layout.alignment: Qt.AlignTop
            Layout.fillWidth: false

            Button {
                id: expandButton
                Layout.fillWidth: true
                text: indicatorItem.expanded ? "Collapse" : "Expand"
                onClicked: indicatorItem.expanded = !indicatorItem.expanded
            }

            Button {
                id: selectButton
                Layout.fillWidth: true
                text: indicatorItem.selected ? "Unselect" : "Select"
                onClicked: indicatorItem.selected = !indicatorItem.selected
            }

            Rectangle {
                Layout.preferredHeight: units.dp(1);
                Layout.fillWidth: true;
                color: "black"
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

            RowLayout {
                Label { text: "Title:" }
                TextField { id: titleLabel; text: "Title"}
            }
        }
    }

    UT.UnityTestCase {
        name: "IndicatorItem"
        when: windowShown

        function init() {
            indicatorItem.selected = false;
            indicatorItem.expanded = false;
            indicatorItem.rootActionState.title = "Test Title";
            indicatorItem.rootActionState.leftLabel = "TestLeftLabel";
            indicatorItem.rootActionState.rightLabel = "TestRightLabel";
            indicatorItem.rootActionState.icons = [ "image://theme/audio-volume-high" ];

            tryCompare(heightAnimation, "running", false);
        }

        function test_expand() {
            indicatorItem.expanded = true;
            tryCompare(indicatorItem, "height", units.gu(7));
            indicatorItem.expanded = false;
            tryCompare(indicatorItem, "height", units.gu(3));
        }

        function test_minimizedVisibility() {
            compare(findChild(indicatorItem, "leftLabel").opacity, 1.0);
            compare(findChild(indicatorItem, "rightLabel").opacity, 1.0);
            compare(findChild(indicatorItem, "icons").opacity, 1.0);
            compare(findChild(indicatorItem, "indicatorName").opacity, 0.0);
        }

        function test_expandIcon() {
            indicatorItem.expanded = true;

            tryCompare(findChild(indicatorItem, "leftLabel"), "opacity", 0.0);
            tryCompare(findChild(indicatorItem, "rightLabel"), "opacity", 0.0);
            tryCompare(findChild(indicatorItem, "icons"), "opacity", 1.0);
            tryCompare(findChild(indicatorItem, "indicatorName"), "opacity", 1.0);
        }

        function test_expandRightLabel() {
            indicatorItem.expanded = true;

            indicatorItem.rootActionState.icons = [];

            tryCompare(findChild(indicatorItem, "leftLabel"), "opacity", 0.0);
            tryCompare(findChild(indicatorItem, "rightLabel"), "opacity", 1.0);
            tryCompare(findChild(indicatorItem, "icons"), "opacity", 0.0);
            tryCompare(findChild(indicatorItem, "indicatorName"), "opacity", 1.0);
        }

        function test_expandLeftLabel() {
            indicatorItem.expanded = true;

            indicatorItem.rootActionState.rightLabel = "";
            indicatorItem.rootActionState.icons = [];

            tryCompare(findChild(indicatorItem, "rightLabel"), "opacity", 0.0);
            tryCompare(findChild(indicatorItem, "leftLabel"), "opacity", 1.0);
            tryCompare(findChild(indicatorItem, "icons"), "opacity", 0.0);
            tryCompare(findChild(indicatorItem, "indicatorName"), "opacity", 1.0);
        }

        function test_select() {
            tryCompare(findChild(indicatorItem, "icon0"), "color", "#ffffff");
            tryCompare(findChild(indicatorItem, "icon0"), "opacity", 1.0);
            tryCompare(findChild(indicatorItem, "leftLabel"), "color", "#ffffff");
            tryCompare(findChild(indicatorItem, "rightLabel"), "color", "#ffffff");
            tryCompare(findChild(indicatorItem, "indicatorName"), "color", "#ffffff");

            indicatorItem.expanded = true;
            tryCompare(findChild(indicatorItem, "icon0"), "color", "#888888");
            tryCompare(findChild(indicatorItem, "icon0"), "opacity", 0.6);
            tryCompare(findChild(indicatorItem, "leftLabel"), "color", "#888888");
            tryCompare(findChild(indicatorItem, "rightLabel"), "color", "#888888");
            tryCompare(findChild(indicatorItem, "indicatorName"), "color", "#888888");

            indicatorItem.selected = true;
            tryCompare(findChild(indicatorItem, "icon0"), "color", "#ffffff");
            tryCompare(findChild(indicatorItem, "icon0"), "opacity", 1.0);
            tryCompare(findChild(indicatorItem, "leftLabel"), "color", "#ffffff");
            tryCompare(findChild(indicatorItem, "rightLabel"), "color", "#ffffff");
            tryCompare(findChild(indicatorItem, "indicatorName"), "color", "#ffffff");
        }
    }
}
