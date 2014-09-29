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
import "../../../../qml/Panel"
import Ubuntu.Components 0.1
import Unity.Test 0.1 as UT
import Unity.Indicators 0.1 as Indicators

IndicatorTest {
    id: root
    width: units.gu(80)
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

            IndicatorsMenu {
                id: indicatorsMenu
                width: units.gu(40)
                anchors {
                    top: parent.top
                    right: parent.right
                }
                minimizedPanelHeight: units.gu(3)
                expandedPanelHeight: units.gu(7)
                openedHeight: parent.height
                indicatorsModel: root.indicatorsModel
                shown: false
            }
        }

        ColumnLayout {
            Layout.alignment: Qt.AlignTop
            Layout.fillWidth: false

            Button {
                Layout.fillWidth: true
                text: indicatorsMenu.shown ? "Hide" : "Show"
                onClicked: {
                    if (indicatorsMenu.shown) {
                        indicatorsMenu.hide();
                    } else {
                        indicatorsMenu.show();
                    }
                }
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
        id: testCase
        name: "IndicatorsMenu"
        when: windowShown

        function init() {
            indicatorsMenu.hide();
            tryCompare(indicatorsMenu.hideAnimation, "running", false);
            compare(indicatorsMenu.state, "initial");
        }

        // Showing the indicators should fully open the indicator panel.
        function test_showAndHide() {
            indicatorsMenu.show();
            tryCompare(indicatorsMenu, "fullyOpened", true);

            indicatorsMenu.hide();
            tryCompare(indicatorsMenu, "fullyClosed", true);
        }

        function test_progress_changes_state_to_reveal() {
            indicatorsMenu.height = indicatorsMenu.openedHeight / 2;
            compare(indicatorsMenu.state, "reveal", "Indicators should be locked when fully opened.");
        }

        function test_progress_changes_state_to_locked() {
            indicatorsMenu.height = indicatorsMenu.openedHeight;
            compare(indicatorsMenu.state, "locked", "Indicators should be locked when fully opened.");
        }

        function test_open_state() {
            compare(indicatorsMenu.fullyClosed, true, "Indicator should show as fully closed.");
            compare(indicatorsMenu.partiallyOpened, false, "Indicator should not show as partially opened");
            compare(indicatorsMenu.fullyOpened, false, "Indicator should not show as fully opened");

            indicatorsMenu.height = indicatorsMenu.openedHeight / 2
            compare(indicatorsMenu.fullyClosed, false, "Indicator should not show as fully closed.");
            compare(indicatorsMenu.partiallyOpened, true, "Indicator should show as partially opened");
            compare(indicatorsMenu.fullyOpened, false, "Indicator should not show as fully opened");

            indicatorsMenu.height = indicatorsMenu.openedHeight;
            compare(indicatorsMenu.fullyClosed, false, "Indicator should not show as fully closed.");
            compare(indicatorsMenu.partiallyOpened, false, "Indicator should show as partially opened");
            compare(indicatorsMenu.fullyOpened, true, "Indicator should not show as fully opened");
        }

        // tests swiping on an indicator item activates the correct item.
        function test_swipeForCurrentItem()
        {
            var indicatorRow = findChild(indicatorsMenu, "indicatorRow")
            verify(indicatorRow !== null);

            for (var i = 0; i < root.indicatorData.length; i++) {
                var indicatorItem = findChild(indicatorsMenu, root.indicatorData[i]["identifier"]+"-panelItem");

                var mappedPosition = root.mapFromItem(indicatorItem,
                        indicatorItem.width/2, indicatorItem.height/2);

                console.log(mappedPosition.x, mappedPosition.y)

                touchFlick(indicatorsMenu,
                           mappedPosition.x, mappedPosition.y,
                           mappedPosition.x, indicatorsMenu.openedHeight / 2,
                           true /* beginTouch */, false /* endTouch */);

                compare(indicatorRow.currentItem, indicatorItem,
                        "Incorrect item activated at position " + i);

                touchFlick(indicatorsMenu,
                           mappedPosition.x, indicatorsMenu.openedHeight / 2,
                           mappedPosition.x, mappedPosition.y,
                           false /* beginTouch */, true /* endTouch */);

                // wait until fully closed
                tryCompare(indicatorsMenu, "fullyClosed", true);
            }
        }

    }
}
