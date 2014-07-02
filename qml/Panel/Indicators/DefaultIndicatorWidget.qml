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

import QtQuick 2.0
import Ubuntu.Components 0.1
import Unity.Indicators 0.1 as Indicators

Indicators.IndicatorBase {
    id: indicatorWidget

    property int iconSize: height
    property alias leftLabel: itemLeftLabel.text
    property alias rightLabel: itemRightLabel.text
    property var icons: undefined

    width: itemRow.width
    enabled: false

    // FIXME: For now we will enable led indicator support only for messaging indicator
    // in the future we should export a led API insted of doing that,
    Loader {
        id: indicatorLed
        // only load source Component if the icons contains the new message icon
        source: (indicatorWidget.icons && (String(indicatorWidget.icons).indexOf("indicator-messages-new") != -1)) ? Qt.resolvedUrl("IndicatorsLight.qml") : ""
    }

    Row {
        id: itemRow
        width: childrenRect.width
        objectName: "itemRow"
        anchors {
            top: parent.top
            bottom: parent.bottom
            horizontalCenter: parent.horizontalCenter
        }

        Label {
            id: itemLeftLabel
            width: guRoundUp(implicitWidth)
            objectName: "leftLabel"
            color: Theme.palette.selected.backgroundText
            opacity: 0.8
            font.family: "Ubuntu"
            fontSize: "medium"
            anchors.verticalCenter: parent.verticalCenter
            visible: text != ""
        }

        Row {
            width: childrenRect.width
            anchors {
                top: parent.top
                bottom: parent.bottom
            }

            Repeater {
                model: indicatorWidget.icons

                Item {
                    width: guRoundUp(itemImage.width)
                    height: indicatorWidget.iconSize

                    Image {
                        id: itemImage
                        objectName: "itemImage"
                        visible: source != ""
                        source: modelData
                        height: parent.height
                        anchors.horizontalCenter: parent.horizontalCenter
                        fillMode: Image.PreserveAspectFit

                        sourceSize {
                            width: indicatorWidget.iconSize
                            height: indicatorWidget.iconSize
                        }
                    }
                }
            }
        }

        Label {
            id: itemRightLabel
            width: guRoundUp(implicitWidth)
            objectName: "rightLabel"
            color: Theme.palette.selected.backgroundText
            opacity: 0.8
            font.family: "Ubuntu"
            fontSize: "medium"
            anchors.verticalCenter: parent.verticalCenter
            visible: text != ""
        }
    }

    // TODO: Use toolkit function https://bugs.launchpad.net/ubuntu-ui-toolkit/+bug/1242575
    function guRoundUp(width) {
        if (width == 0) {
            return 0;
        }
        var gu1 = units.gu(1.0);
        var mod = (width % gu1);

        return mod == 0 ? width : width + (gu1 - mod);
    }

    onRootActionStateChanged: {
        if (rootActionState == undefined) {
            leftLabel = "";
            rightLabel = "";
            icons = undefined;
            enabled = false;
            return;
        }

        leftLabel = rootActionState.leftLabel ? rootActionState.leftLabel : "";
        rightLabel = rootActionState.rightLabel ? rootActionState.rightLabel : "";
        icons = rootActionState.icons;
        enabled = rootActionState.visible;
    }
}
