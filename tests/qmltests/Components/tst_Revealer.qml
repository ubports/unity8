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
import Unity.Test 0.1 as UT
import ".."

/*
  There's a revealer on each window edge. If you press and hold any edge you
  should see a black bar appearing from that edge. If you them slide the
  pointer/finger towards the opposite edge, that black bar should follow
  the movement up to around the center of the window. Next to the black bar,
  which represents the "handle" area of the Revealer, You should see a red rectangle,
  which is the main body of the Showable concrolled by the Revealer (Showable = red
  + black rects).
 */
Item {
    width: units.gu(75)
    height: units.gu(50)

    RevealingRectangle {
        id: topRevealingRectangle
        anchors.fill: parent
        orientation: Qt.Vertical
        direction: Qt.LeftToRight
    }

    RevealingRectangle {
        id: bottomRevealingRectangle
        anchors.fill: parent
        orientation: Qt.Vertical
        direction: Qt.RightToLeft
    }

    RevealingRectangle {
        id: leftRevealingRectangle
        anchors.fill: parent
        orientation: Qt.Horizontal
        direction: Qt.LeftToRight
    }

    RevealingRectangle {
        id: rightRevealingRectangle
        anchors.fill: parent
        orientation: Qt.Horizontal
        direction: Qt.RightToLeft
    }

    UT.UnityTestCase {
        name: "Revealer"
        when: windowShown

        /*
           A bit of the showable should be displayed when you press over the
           handle area of the Revealer.

           Once released, it should go out of sight again.
        */
        function test_showHintOnPress() {
            var revealer = topRevealingRectangle.revealer
            var showable = topRevealingRectangle.showable

            // It starts out of sight
            compare(showable.y, -showable.height)

            // (item, x, y, button, modifiers, delay)
            mousePress(revealer,
                       revealer.width/2,
                       revealer.handleSize/2,
                       Qt.LeftButton, Qt.NoModifier, 0);

            tryCompare(showable, "y", -showable.height + revealer.handleSize)

            // (item, x, y, button, modifiers, delay)
            mouseRelease(revealer,
                         revealer.width/2,
                         revealer.handleSize/2,
                         Qt.LeftButton, Qt.NoModifier, 0);

            tryCompare(showable, "y", -showable.height)
        }

        /*
          Press over the handle area of the Revealer and drag it to pull
          its target Showable. Release it half-way and the Showable will
          continue moving by itself until it's completely shown.


          Press over the handle area and drag it back to hide the Showable.
          Release it half-way and it will continue moving by itself until it's
          completely hidden again.
         */
        function test_dragToRevealAndDragBackToHide_top() {
            var revealer = topRevealingRectangle.revealer
            var showable = topRevealingRectangle.showable
            revealer.__dateTime = fakeDateTime

            // It starts out of sight
            compare(showable.y, -showable.height)

            mouseFlick(revealer,
                       revealer.width/2, // from_x
                       revealer.handleSize/2, // from_y
                       revealer.width/2, // to_x
                       showable.height/2); // to_y

            // Should eventually get fully extended
            tryCompare(showable, "y", 0)

            // Now drag it back to get it hidden

            mouseFlick(revealer,
                       revealer.width/2,
                       showable.height - (revealer.handleSize/2),
                       revealer.width/2,
                       showable.height/2)

            // Should eventually be completely out of sight
            tryCompare(showable, "y", -showable.height)
        }

        function test_dragToRevealAndDragBackToHide_bottom() {
            var revealer = bottomRevealingRectangle.revealer
            var showable = bottomRevealingRectangle.showable
            var revRect = bottomRevealingRectangle
            revealer.__dateTime = fakeDateTime

            // It starts out of sight
            compare(showable.y, revRect.height)

            mouseFlick(revealer,
                       revealer.width/2, // from_x
                       revealer.height - revealer.handleSize/2, // from_y
                       revealer.width/2, // to_x
                       revealer.height - showable.height/2); // to_y

            // Should eventually get fully extended
            tryCompare(showable, "y", revRect.height - showable.height)

            // Now drag it back to get it hidden

            mouseFlick(revealer,
                       revealer.width/2,
                       revealer.handleSize/2,
                       revealer.width/2,
                       revealer.height - showable.height/2)

            // Should eventually be completely out of sight
            tryCompare(showable, "y", revRect.height)
        }

        function test_dragToRevealAndDragBackToHide_left() {
            var revealer = leftRevealingRectangle.revealer
            var showable = leftRevealingRectangle.showable
            revealer.__dateTime = fakeDateTime

            // It starts out of sight
            compare(showable.x, -showable.width)

            mouseFlick(revealer,
                       revealer.handleSize/2, // from_x
                       revealer.height/2, // from_y
                       showable.width/2, // to_x
                       revealer.height/2) // to_y

            // Should eventually get fully extended
            tryCompare(showable, "x", 0)

            // Now drag it back to get it hidden

            mouseFlick(revealer,
                       showable.width - (revealer.handleSize/2),
                       revealer.height/2,
                       showable.width/2,
                       revealer.height/2)

            // Should eventually be completely out of sight
            tryCompare(showable, "x", -showable.width)
        }

        function test_dragToRevealAndDragBackToHide_right() {
            var revealer = rightRevealingRectangle.revealer
            var showable = rightRevealingRectangle.showable
            var revRect = rightRevealingRectangle
            revealer.__dateTime = fakeDateTime

            // It starts out of sight
            compare(showable.x, revRect.width)

            mouseFlick(revealer,
                       revealer.width - revealer.handleSize/2, // from_x
                       revealer.height/2, // from_y
                       revealer.width - showable.width/2, // to_x
                       revealer.height/2) // to_y

            // Should eventually get fully extended
            tryCompare(showable, "x", revRect.width - showable.width)

            // Now drag it back to get it hidden

            mouseFlick(revealer,
                       revealer.handleSize/2,
                       revealer.height/2,
                       revealer.width - showable.width/2,
                       revealer.height/2)

            // Should eventually be completely out of sight
            tryCompare(showable, "x", revRect.width)
        }

        /*
          Start dragging down (pulling the showable into view) and then,
          midway, drag a bit upwards and release it.
          The showable should keep moving away, ending up hidden again.
         */
        function test_dragForthAndBackReturnsOriginalState() {
            var revealer = topRevealingRectangle.revealer
            var showable = topRevealingRectangle.showable
            revealer.__dateTime = fakeDateTime

            // It starts out of sight
            compare(showable.y, -showable.height)

            mouseFlick(revealer,
                       revealer.width/2, // from_x
                       revealer.handleSize/2, // from_y
                       revealer.width/2, // to_x
                       showable.height/2, // to_y
                       true /* do press */, false /* don't release */);

            // Should be about half-extended
            verify(showable.y > -showable.height*3/4)
            verify(showable.y < -showable.height*1/4)


            // Now drag it back a bit
            mouseFlick(revealer,
                       revealer.width/2, // from_x
                       showable.height/2, // from_y
                       revealer.width/2, // to_x
                       showable.height/4, // to_y
                       false /* don't press */, true /* do release */);

            // Should eventually be completely out of sight again
            tryCompare(showable, "y", -showable.height)
        }
    }
}
