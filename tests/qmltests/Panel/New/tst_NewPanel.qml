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
import Unity.Test 0.1 as UT
import Ubuntu.Components 0.1
import Unity.Indicators 0.1 as Indicators
import "../../../../qml/Panel"

IndicatorTest {
    id: root
    width: units.gu(100)
    height: units.gu(71)
    color: "white"

    RowLayout {
        anchors.fill: parent
        anchors.margins: units.gu(1)

        Rectangle {
            Layout.fillWidth: true
            Layout.fillHeight: true

            id: itemArea
            color: "blue"

            Panel {
                id: panel
                anchors.fill: parent
                indicators {
                    width: parent.width > units.gu(60) ? units.gu(40) : parent.width
                    indicatorsModel: root.indicatorsModel
                }
            }
        }

        ColumnLayout {
            Layout.alignment: Qt.AlignTop
            Layout.fillWidth: false

            Button {
                Layout.fillWidth: true
                text: panel.indicators.shown ? "Hide" : "Show"
                onClicked: {
                    if (panel.indicators.shown) {
                        panel.indicators.hide();
                    } else {
                        panel.indicators.show();
                    }
                }
            }

            Button {
                text: panel.fullscreenMode ? "Maximize" : "FullScreen"
                Layout.fillWidth: true
                onClicked: panel.fullscreenMode = !panel.fullscreenMode
            }


            Rectangle {
                Layout.preferredHeight: units.dp(1);
                Layout.fillWidth: true;
                color: "black"
            }

            Repeater {
                model: root.indicatorData
                RowLayout {
                    CheckBox {
                        checked: true
                        onCheckedChanged: checked ? insertIndicator(index) : removeIndicator(index);
                    }
                    Label { text: modelData["identifier"] }
                }
            }
        }
    }

    UT.UnityTestCase {
        name: "Panel"
        when: windowShown
    }
}
