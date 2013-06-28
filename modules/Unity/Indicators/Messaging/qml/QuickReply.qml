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
 *      Renato Araujo Oliveira Filho <renato@canonical.com>
 *      Olivier Tilloy <olivier.tilloy@canonical.com>
 */

import QtQuick 2.0
import Ubuntu.Components 0.1
import Unity.Indicators 0.1 as Indicators

Item {
    property alias actionGroup: __actionTextField.actionGroup
    property alias action: __actionTextField.action

    property alias buttonText: __actionTextField.buttonText
    property real expandedHeight: childrenRect.height
    property alias messages : __messagelistRepeater.model

    Item {
        id: __header
        anchors.top: parent.top
        anchors.left: parent.left
        anchors.right: parent.right
        height: units.gu(4)

        Row {
            anchors.fill: parent
            anchors.leftMargin: units.gu(2)
            anchors.rightMargin: units.gu(2)
            anchors.topMargin: units.gu(1)
            anchors.bottomMargin: units.gu(1)
            spacing: units.gu(1)

            Image {
                width: units.gu(2)
                height: width
                fillMode: Image.PreserveAspectFit
                source: "qrc:/indicators/artwork/messaging/message_sms01_54px.png"
            }

            Label {
                height: parent.height
                verticalAlignment: Text.AlignVCenter
                fontSize: "small"
                color: "#8f8f88"
                text: "Quick reply with:"
            }
        }

        Indicators.HLine {
            anchors.bottom: parent.bottom
            color: "#20201F"
        }
    }

    Column {
        id: __messagelist
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.top: __header.bottom
        height: childrenRect.height

        Repeater {
            id: __messagelistRepeater

            height: childrenRect.height

            Rectangle {
                width: __messagelist.width
                height: units.gu(5)
                color: "#333230"

                Label {
                    id: __label

                    anchors.fill: parent
                    anchors.leftMargin: units.gu(2)
                    anchors.rightMargin: units.gu(2)
                    verticalAlignment: Text.AlignVCenter
                    fontSize: "medium"
                    color: "#e8e1d0"
                    text: modelData
                }

                Indicators.HLine {
                    anchors.top: parent.top
                    color: "#464543"
                }

                Indicators.HLine {
                    anchors.bottom: parent.bottom
                    color: "#20201F"
                }

                MouseArea {
                    id: __mouseArea

                    anchors.fill: parent
                    onClicked: {
                        __actionTextField.text = modelData;
                    }
                }

                Rectangle {
                    id: __mask

                    anchors.fill: parent
                    color: "black"
                    opacity: __mouseArea.pressed ? 0.3 : 0.0
                    Behavior on opacity {
                        NumberAnimation {
                            duration: 200
                            easing.type: Easing.OutQuad
                        }
                    }
                }
            }

        }
    }

    Item {
        anchors.top: __messagelist.bottom
        anchors.left: parent.left
        anchors.right: parent.right
        height: units.gu(6)

        ActionTextField {
            id: __actionTextField

            anchors.fill: parent
            anchors.margins: units.gu(1)
        }

        Indicators.HLine {
            anchors.top: parent.top
            color: "#464543"
        }
    }
}
