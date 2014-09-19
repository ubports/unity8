/*
 * Copyright 2013 Canonical Ltd.
 *
 * This program is free software; you can redistribute it and/or modify
 * it under the terms of the GNU Lesser General Public License as published by
 * the Free Software Foundation; version 3.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU Lesser General Public License for more details.
 *
 * You should have received a copy of the GNU Lesser General Public License
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.
 *
 * Authors:
 *      Nick Dedekind <nick.dedekind@canonical.com>
 */

import QtQuick 2.1
import Ubuntu.Components 0.1
import Ubuntu.Settings.Components 0.1
import "../Indicators"

IndicatorBase {
    id: root

    property alias title: indicatorName.text
    property alias leftLabel: itemLeftLabel.text
    property alias rightLabel: itemRightLabel.text
    property var icons: undefined
    property bool expanded: false
    property bool selected: false

    signal clicked()

    width: mainItems.width
    enabled: false

    MouseArea {
        anchors.fill: parent
        onClicked: parent.clicked()
    }

    // FIXME: For now we will enable led indicator support only for messaging indicator
    // in the future we should export a led API insted of doing that,
    Loader {
        id: indicatorLed
        // only load source Component if the icons contains the new message icon
        source: (root.icons && (String(root.icons).indexOf("indicator-messages-new") != -1)) ? Qt.resolvedUrl("IndicatorsLight.qml") : ""
    }

    Item {
        id: mainItems
        anchors.centerIn: parent

        width: itemLeftLabel.width + iconsItem.width + itemRightLabel.width
        implicitHeight: units.gu(2)

        Label {
            id: itemLeftLabel
            anchors {
                left: mainItems.left
                verticalCenter: parent.verticalCenter
            }
            width: contentWidth > 0 ? contentWidth + units.gu(1) : 0
            horizontalAlignment: Text.AlignHCenter

            objectName: "leftLabel"
            opacity: 0.8
            font.family: "Ubuntu"
            fontSize: "medium"
            color: {
                if (!expanded) return Theme.palette.normal.foregroundText;
                if (!selected) return Theme.palette.selected.backgroundText;
                return Theme.palette.normal.foregroundText;
            }
            Behavior on color { ColorAnimation{ duration: UbuntuAnimation.SnapDuration } }
        }

        Item {
            id: iconsItem
            width: iconRow.width > 0 ? iconRow.width + units.gu(1) : 0
            anchors {
                left: itemLeftLabel.right
                verticalCenter: parent.verticalCenter
            }

            Row {
                id: iconRow
                anchors.centerIn: iconsItem
                spacing: units.gu(1)

                Repeater {
                    id: iconRepeater
                    model: d.useFallbackIcon ? [ "image://theme/settings" ] : root.icons

                    StatusIcon {
                        id: itemImage
                        height: units.gu(2)
                        source: modelData
                        sets: ["status", "actions"]
                        color: {
                            if (!expanded) return Theme.palette.normal.foregroundText;
                            if (!selected) return Theme.palette.selected.backgroundText;
                            return Theme.palette.normal.foregroundText;
                        }
                        Behavior on color { ColorAnimation{ duration: 1 } }
                    }
                }
            }
        }

        Label {
            id: itemRightLabel
            anchors {
                left: iconsItem.right
                verticalCenter: parent.verticalCenter
            }
            width: contentWidth > 0 ? contentWidth + units.gu(1) : 0
            horizontalAlignment: Text.AlignHCenter

            objectName: "rightLabel"
            opacity: 0.8
            font.family: "Ubuntu"
            fontSize: "medium"
            color: {
                if (!expanded) return Theme.palette.normal.foregroundText;
                if (!selected) return Theme.palette.selected.backgroundText;
                return Theme.palette.normal.foregroundText;
            }
            Behavior on color { ColorAnimation{ duration: UbuntuAnimation.SnapDuration } }
        }
    }

    Label {
        id: indicatorName

        anchors.top: mainItems.bottom
        anchors.topMargin: units.gu(0.5)
        anchors.horizontalCenter: parent.horizontalCenter
        width: contentWidth > 0 ? contentWidth + units.gu(1) : 0

        text: rootActionState.title
        fontSize: "x-small"
        horizontalAlignment: Text.AlignHCenter
        opacity: 0
        color: {
            if (!expanded) return Theme.palette.normal.foregroundText;
            if (!selected) return Theme.palette.selected.backgroundText;
            return Theme.palette.normal.foregroundText;
        }
        Behavior on color { ColorAnimation{ duration: UbuntuAnimation.SnapDuration } }
    }

    StateGroup {
        id: d
        property bool useFallbackIcon: false


        states: [
            State {
                name: "minimised"
                when: !expanded && ((icons && icons.length > 0) || leftLabel !== "" || rightLabel !== "")
                PropertyChanges { target: indicatorName; opacity: 0}
            },

            State {
                name: "minimised_fallback"
                when: !expanded && (!icons || icons.length === 0) && leftLabel == "" && rightLabel == ""
                PropertyChanges { target: indicatorName; opacity: 0}
                PropertyChanges { target: d; useFallbackIcon: true }
            },

            State {
                name: "expanded_icon"
                when: expanded && (icons && icons.length > 0)
                PropertyChanges { target: indicatorName; visible: true; opacity: 1}
                AnchorChanges { target: iconsItem; anchors.left: undefined; anchors.horizontalCenter: parent.horizontalCenter }
                AnchorChanges { target: itemLeftLabel; anchors.left: undefined; anchors.right: iconsItem.left }
                PropertyChanges { target: itemLeftLabel; opacity: 0 }
                PropertyChanges { target: mainItems; width: Math.max(iconsItem.width, indicatorName.width); anchors.verticalCenterOffset: -units.gu(1) }
                PropertyChanges { target: itemLeftLabel; opacity: 0 }
                PropertyChanges { target: itemRightLabel; opacity: 0 }
            },

            State {
                name: "expanded_fallback"
                when: expanded && (!icons || icons.length === 0) && leftLabel == "" && rightLabel == ""
                PropertyChanges { target: d; useFallbackIcon: true }
                PropertyChanges { target: indicatorName; visible: true; opacity: 1}
                AnchorChanges { target: iconsItem; anchors.left: undefined; anchors.horizontalCenter: parent.horizontalCenter }
                AnchorChanges { target: itemLeftLabel; anchors.left: undefined; anchors.right: iconsItem.left }
                PropertyChanges { target: itemLeftLabel; opacity: 0 }
                PropertyChanges { target: mainItems; width: Math.max(iconsItem.width, indicatorName.width); anchors.verticalCenterOffset: -units.gu(1) }
                PropertyChanges { target: itemLeftLabel; opacity: 0 }
                PropertyChanges { target: itemRightLabel; opacity: 0 }
            },

            State {
                name: "expanded_rightLabel"
                when: expanded && (!icons || icons.length === 0) && rightLabel !== ""
                PropertyChanges { target: indicatorName; visible: true; opacity: 1}
                AnchorChanges { target: itemRightLabel; anchors.left: undefined; anchors.horizontalCenter: parent.horizontalCenter }
                PropertyChanges { target: mainItems; width: Math.max(itemRightLabel.width, indicatorName.width); anchors.verticalCenterOffset: -units.gu(1) }
                PropertyChanges { target: iconsItem; opacity: 0 }
                PropertyChanges { target: itemLeftLabel; opacity: 0 }
            },

            State {
                name: "expanded_leftLabel"
                when: expanded && (!icons || icons.length === 0) && leftLabel !== ""
                PropertyChanges { target: indicatorName; visible: true; opacity: 1}
                AnchorChanges { target: itemLeftLabel; anchors.left: undefined; anchors.horizontalCenter: parent.horizontalCenter }
                PropertyChanges { target: mainItems; width: Math.max(itemLeftLabel.width, indicatorName.width); anchors.verticalCenterOffset: -units.gu(1) }
                PropertyChanges { target: iconsItem; opacity: 0 }
                PropertyChanges { target: itemRightLabel; opacity: 0 }
            }
        ]

        transitions: [
            Transition {
                PropertyAction { target: d; property: "useFallbackIcon"}
                AnchorAnimation {
                    targets: [ mainItems, iconsItem, itemLeftLabel, itemRightLabel ]
                    duration: UbuntuAnimation.SnapDuration; easing: UbuntuAnimation.StandardEasing
                }
                PropertyAnimation {
                    targets: [ mainItems, iconsItem, itemLeftLabel, itemRightLabel, indicatorName ]
                    properties: "width, opacity, anchors.verticalCenterOffset";
                    duration: UbuntuAnimation.SnapDuration; easing: UbuntuAnimation.StandardEasing
                }
            }
        ]
    }

    onRootActionStateChanged: {
        if (rootActionState == undefined) {
            leftLabel = "";
            rightLabel = "";
            icons = undefined;
            enabled = false;
            return;
        }

        title = rootActionState.title ? rootActionState.title : "";
        leftLabel = rootActionState.leftLabel ? rootActionState.leftLabel : "";
        rightLabel = rootActionState.rightLabel ? rootActionState.rightLabel : "";
        icons = rootActionState.icons;
        enabled = rootActionState.visible;
    }
}
