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

import QtQuick 2.0
import QtTest 1.0
import ".."
import "../../../Components"
import Ubuntu.Components.ListItems 0.1 as ListItem
import Ubuntu.Components 0.1
import Unity.Test 0.1 as UT

Item {
    id: root
    width: units.gu(40)
    height: units.gu(80)

    ListModel {
        id: animalsModel
        ListElement { name: "Parrot"; size: "Small" }
        ListElement { name: "Guinea pig"; size: "Small" }
        ListElement { name: "Mouse"; size: "Small" }
        ListElement { name: "Sparrow"; size: "Small" }
        ListElement { name: "Dog"; size: "Medium" }
        ListElement { name: "Cat"; size: "Medium" }
        ListElement { name: "Dolphin"; size: "Medium" }
        ListElement { name: "Seal"; size: "Medium" }
        ListElement { name: "Elephant"; size: "Large" }
        ListElement { name: "Blue whale"; size: "Large" }
        ListElement { name: "Rhino"; size: "Large" }
        ListElement { name: "Ostrich"; size: "Large" }
        ListElement { name: "Sperm whale"; size: "Large" }
        ListElement { name: "Giraffe"; size: "Large" }
        ListElement { name: "Parrot"; size: "Small" }
        ListElement { name: "Guinea pig"; size: "Small" }
        ListElement { name: "Mouse"; size: "Small" }
        ListElement { name: "Sparrow"; size: "Small" }
        ListElement { name: "Dog"; size: "Medium" }
        ListElement { name: "Cat"; size: "Medium" }
        ListElement { name: "Dolphin"; size: "Medium" }
        ListElement { name: "Seal"; size: "Medium" }
        ListElement { name: "Elephant"; size: "Large" }
        ListElement { name: "Blue whale"; size: "Large" }
        ListElement { name: "Rhino"; size: "Large" }
        ListElement { name: "Ostrich"; size: "Large" }
        ListElement { name: "Sperm whale"; size: "Large" }
        ListElement { name: "Giraffe"; size: "Large" }
        ListElement { name: "Parrot"; size: "Small" }
        ListElement { name: "Guinea pig"; size: "Small" }
        ListElement { name: "Mouse"; size: "Small" }
        ListElement { name: "Sparrow"; size: "Small" }
        ListElement { name: "Dog"; size: "Medium" }
        ListElement { name: "Cat"; size: "Medium" }
        ListElement { name: "Dolphin"; size: "Medium" }
        ListElement { name: "Seal"; size: "Medium" }
        ListElement { name: "Elephant"; size: "Large" }
        ListElement { name: "Blue whale"; size: "Large" }
        ListElement { name: "Rhino"; size: "Large" }
        ListElement { name: "Ostrich"; size: "Large" }
        ListElement { name: "Sperm whale"; size: "Large" }
        ListElement { name: "Giraffe"; size: "Large" }
        ListElement { name: "Parrot"; size: "Small" }
        ListElement { name: "Guinea pig"; size: "Small" }
        ListElement { name: "Mouse"; size: "Small" }
        ListElement { name: "Sparrow"; size: "Small" }
        ListElement { name: "Dog"; size: "Medium" }
        ListElement { name: "Cat"; size: "Medium" }
        ListElement { name: "Dolphin"; size: "Medium" }
        ListElement { name: "Seal"; size: "Medium" }
        ListElement { name: "Elephant"; size: "Large" }
        ListElement { name: "Blue whale"; size: "Large" }
        ListElement { name: "Rhino"; size: "Large" }
        ListElement { name: "Ostrich"; size: "Large" }
        ListElement { name: "Sperm whale"; size: "Large" }
        ListElement { name: "Giraffe"; size: "Large" }
    }

    ListViewWithPageHeader {
        id: listView
        anchors.fill: parent
        model: animalsModel

        delegate: Item {
            height: units.gu(6)
            anchors {
                left: parent.left
                right: parent.right
            }

            Label {
                id: label
                anchors.fill: parent
                text: name
                verticalAlignment: Text.AlignVCenter
            }
        }

        sectionProperty: "size"
        sectionDelegate: Rectangle {
            anchors {
                left: (parent) ? parent.left : undefined
                right: (parent) ? parent.right : undefined
            }
            height: units.gu(5)
            color: "lightsteelblue"

            Label {
                id: label
                anchors.fill: parent
                text: section
                verticalAlignment: Text.AlignVCenter
            }
        }

        pageHeader: PageHeader {
            id: pageHeader
            anchors {
                left: parent.left
                right: parent.right
            }
            text: "Animals"
        }
    }




    UT.UnityTestCase {
        name: "ListViewWithPageHeader"
        when: windowShown

        readonly property real xPos: listView.width / 2
        readonly property real headerHeight: pageHeader.height

    /**************************** Helper functions ****************************/
        function listViewFirstSectionHeaderYPosition() {
            return Math.round(listView.pageHeader.mapToItem(listView).y); //round as using floats
        }

        function firstSectionHeaderYPosition() {
            return Math.round(listView.view.children[0].mapToItem(listView).y);
        }

        function cleanup() {
            listView.positionAtBeginning();
            // wait for list position to reset
            tryCompareFunction(listViewFirstSectionHeaderYPosition, 0);
            tryCompare(listView.view.contentY, 0);
        }

        // these functions are hand-crafted to move the Flickable down/up one pixel
        function swipeDown1Pixel(item) {
            mousePress(item, xPos, 15);
            mouseMove(item, xPos, 14, 100);
            mouseMove(item, xPos, 10, 100);
            mouseMove(item, xPos, 6, 100);
            mouseMove(item, xPos, 3, 100);
            mouseMove(item, xPos, 1, 100);
            mouseMove(item, xPos, 0, 100);
            mouseRelease(item, xPos, 0);
        }

        function swipeUp1Pixel(item) {
            mousePress(item, xPos, 0);
            mouseMove(item, xPos, 1, 100);
            mouseMove(item, xPos, 5, 100);
            mouseMove(item, xPos, 9, 100);
            mouseMove(item, xPos, 12, 100);
            mouseMove(item, xPos, 14, 100);
            mouseMove(item, xPos, 15, 100);
            mouseRelease(item, xPos, 15);
        }

    /******************************* Test cases *******************************/

        /* Check the initial positions of components are correct */
        function test_initialState() {
            compare(listViewFirstSectionHeaderYPosition(), 0);
            compare(listView.view.contentY, 0);

            // Check that the section delegate is positioned underneath the header
            // First section delegate is the first child of the view
            tryCompareFunction(firstSectionHeaderYPosition, headerHeight);
        }

        /* Check the header moves up one pixel when the view is moved up by one pixel */
        function test_headerPositionAfterDownMoveByOnePixel() {
            swipeDown1Pixel(listView)

            tryCompareFunction(listViewFirstSectionHeaderYPosition, -1);
            tryCompareFunction(firstSectionHeaderYPosition, headerHeight - 1);
            tryCompare(listView.view.contentY, -1);
        }

        /* Check the header position is y=0 when view moved up and then down by one pixel */
        function test_headerPositionAfterDownAndThenUpMoveByOne() {
            swipeDown1Pixel(listView)

            tryCompareFunction(listViewFirstSectionHeaderYPosition, -1);
            tryCompare(listView.view.contentY, -1);

            // these operations move the Flickabe up one pixel
            swipeUp1Pixel(listView);

            tryCompare(listView.view.contentY, 0);
            // tryCompareFunction(listViewFirstSectionHeaderYPosition, 0) //FIXME - this fails due to bug in LVWPH
            tryCompareFunction(firstSectionHeaderYPosition, headerHeight)
        }

        /* Check after a big flick the header is moved off-screen, with the header bottom
           placed just above the view */
        function test_headerPositionAfterDownMove() {
            // move the Flickabe up to hide header
            listView.flick(0, -10000);

            // wait for flick to finish
            tryCompare(listView.moving, false);

            tryCompareFunction(listViewFirstSectionHeaderYPosition, -headerHeight);
        }

        /* Check when header off-screen, moving down the view by one pixel moves the header
           down by one pixel */
        function test_hiddenHeaderPositionAfterUpMoveByOnePixel() {
            // move the Flickabe up to hide header
            listView.flick(0, -10000);

            // wait for flick to fully hide header
            tryCompareFunction(listViewFirstSectionHeaderYPosition, -headerHeight);

            swipeUp1Pixel(listView);

            tryCompareFunction( function() {
                return Math.floor( listViewFirstSectionHeaderYPosition() ); // need to round to make test more robust
            }, -headerHeight + 1);
        }

        /* Check if up swipe causes list to bounces at the bottom, header stays hidden */
        function test_upSwipeCausingBounceKeepsHeaderHidden() {
            // move list to the bottom (will bounce)
            listView.flick(0, -1000000);

            // wait for bounce to complete
            tryCompare(listView.moving, false);
            tryCompare(listView.view.atYEnd, true);

            tryCompareFunction(listViewFirstSectionHeaderYPosition, -headerHeight);
        }

        /* Check if up swipe causes list to bounces at the bottom, header stays hidden */
        function test_downSwipeCausingBounceKeepsHeaderVisible() {
            // move list to the bottom (will bounce)
            listView.flick(0, -1000000);

            // wait for bounce to complete
            tryCompare(listView.moving, false);
            tryCompare(listView.view.atYBeginning, true);

            tryCompareFunction(listViewFirstSectionHeaderYPosition, 0);
        }

        /* Check if list at top is pulled down further, that the list contents move but the
           header remains at the top of the view */
        function test_topDragOverBoundsKeepsHeaderVisible() {
            // drag list up - but don't release yet
            mouseFlick(listView,
                       xPos, // from_x
                       0,    // from_y
                       xPos, // to_x
                       100, true, false, 0.2);

            // wait for gesture to occur
            tryCompareFunction(function() { return listView.view.contentY < 20; }, true);
            tryCompareFunction(listViewFirstSectionHeaderYPosition, 0);

            mouseRelease(listView, xPos, 400);

            // ensure list moving to recover from over-bound drag keeps header unchanged
            tryCompare(listView.view.contentY, 0);
            tryCompareFunction(listViewFirstSectionHeaderYPosition, 0);
        }

        /* Check if list at top is pulled down further, that the list contents move but the
           header remains at the top of the view */
        function test_bottomDragOverBoundsKeepsHeaderHidden() {
            // move list to the bottom (will bounce)
            listView.flick(0, -1000000);

            // wait for bounce to complete
            tryCompare(listView.moving, false);
            tryCompare(listView.view.atYEnd, true);

            // drag list up but don't release
            mouseFlick(listView,
                       xPos, // from_x
                       0,    // from_y
                       xPos, // to_x
                       -listView.height, true, false);

            tryCompareFunction(listViewFirstSectionHeaderYPosition, -headerHeight);

            mouseRelease(listView, xPos, -listView.height);
            // wait for list to reset position
            tryCompare(listView.moving, false);
            tryCompare(listView.view.atYEnd, true);

            // ensure list moving to recover from over-bound drag keeps header unchanged
            tryCompareFunction(listViewFirstSectionHeaderYPosition, -headerHeight);
        }

        /* Check positionAtBeginning() works resets list and header position */
        function test_positionAtBeginning() {
            // move the Flickabe up to hide header
            listView.flick(0, -10000);

            // wait for gesture to complete
            tryCompare(listView.moving, false);

            listView.positionAtBeginning();
            tryCompareFunction(listViewFirstSectionHeaderYPosition, 0);
            tryCompare(listView.view.contentY, 0);
        }

        /* Check showHeader forces header to appear but list position remains unchanged */
        function test_showHeader() {
            // move the Flickabe up to hide header
            listView.flick(0, -10000);

            // wait for gesture to complete
            tryCompare(listView.moving, false);

            var listContentY = listView.view.contentY;

            listView.showHeader();
            tryCompareFunction(listViewFirstSectionHeaderYPosition, 0);
            tryCompare(listView.view.contentY, listContentY);
        }
    }
}
