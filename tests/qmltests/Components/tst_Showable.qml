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

import QtQuick 2.4
import QtTest 1.0
import Ubuntu.Components 1.3
import Unity.Test 0.1 as UT
import ".."
import "../../../qml/Components"

/*
  There will be 3 stacked rectangles, red, green & blue. Initially they
  will be partially transparent.

  Clicking a rectangle will turn it opaque, and cause the other two to become partially transparent (hidden).
  This transparency change is the animation change set for the show/hide of the showable.
*/
Item {
    width: units.gu(40)
    height: units.gu(60)

    Showable {
        id: show1
        anchors.left: parent.left
        anchors.top: parent.top
        anchors.right: parent.right
        height: units.gu(20)

        opacity: 0.2
        shown: false
        hides: [show2, show3]
        showAnimation: StandardAnimation { property: "opacity"; duration: 350; to: 1.0; easing.type: Easing.OutCubic }
        hideAnimation: StandardAnimation { property: "opacity"; duration: 350; to: 0.2; easing.type: Easing.OutCubic }

        Rectangle {
            anchors.fill: parent
            color: "red"
        }
        MouseArea {
            anchors.fill: parent
            onClicked: { parent.show() }
        }
    }

    Showable {
        id: show2
        anchors.left: parent.left
        anchors.top: show1.bottom
        anchors.right: parent.right
        height: units.gu(20)

        opacity: 0.2
        shown: false
        hides: [show1, show3]
        showAnimation: StandardAnimation { property: "opacity"; duration: 350; to: 1.0; easing.type: Easing.OutCubic }
        hideAnimation: StandardAnimation { property: "opacity"; duration: 350; to: 0.2; easing.type: Easing.OutCubic }

        Rectangle {
            anchors.fill: parent
            color: "green"
        }
        MouseArea {
            anchors.fill: parent
            onClicked: { parent.show() }
        }
    }

    Showable {
        id: show3
        anchors.left: parent.left
        anchors.top: show2.bottom
        anchors.right: parent.right
        anchors.bottom: parent.bottom

        opacity: 0.1
        shown: false
        hides: [show1, show2]
        showAnimation: StandardAnimation { property: "opacity"; duration: 350; to: 1.0; easing.type: Easing.OutCubic }
        hideAnimation: StandardAnimation { property: "opacity"; duration: 350; to: 0.2; easing.type: Easing.OutCubic }

        Rectangle {
            anchors.fill: parent
            color: "blue"
        }
        MouseArea {
            anchors.fill: parent
            onClicked: { parent.show() }
        }
    }

    UT.UnityTestCase {
        name: "Showable"
        when: windowShown

        function init_test() {
            show1.hide();
            show2.hide();
            show3.hide();
        }

        // Test that the showable is shown when the abailable flag is set
        function test_available_show() {
            init_test();

            show1.available = true;
            show1.show();
            compare(show1.shown, true, "Showable should show if available");
        }

        // Test that the showable is not shown when the abailable flag is not set
        function test_unavailable_show() {
            init_test();

            show1.available = false;
            show1.show();
            compare(show1.shown, false, "Showable should not show if shown when not available");
        }

        // Test that showing the showable hides the showables in it's [hides] poperty
        function test_show_hides_others() {
            init_test();

            show1.show();
            compare(show1.shown, true, "Showable should show if available");
            compare(show2.shown, false, "show2 should be hidden when show1 is shown");
            compare(show2.shown, false, "show3 should be hidden when show1 is shown");

            show2.show();
            compare(show1.shown, false, "show1 should be hidden when show2 is shown");
            compare(show2.shown, true, "Showing show2 should show it");
            compare(show3.shown, false, "show3 should be hidden when show2 is shown");
        }

        // Test the lazy show mechnism while waiting for the created flag.
        function test_show_when_not_created() {
            init_test();

            show1.created = false;

            show1.show();
            compare(show1.shown, false, "Showable should not show when created == false");
            show1.created = true;
            compare(show1.shown, true, "Showable should automatically show when created changes to true if attempted to show before.");
        }

        // Test that showNow immediately shows showable
        function test_showNow() {
            init_test();

            show1.opacity = 0.2;

            show1.showNow();
            compare(show1.shown, true, "Showable should be shown after showNow");
            compare(show1.showAnimation.running, false, "Showable should be done running after showNow");
            compare(show1.opacity, 1.0, "Showable should be at end of animation after showNow");
        }

        // Test the lazy showNow mechanism while waiting for the created flag.
        function test_showNow_when_not_created() {
            init_test();

            show1.opacity = 0.2;
            show1.created = false;

            show1.showNow();
            compare(show1.shown, false, "Showable should not showNow when created == false");
            show1.created = true;
            compare(show1.shown, true, "Showable should automatically show when created changes to true if attempted to showNow before.");
            compare(show1.showAnimation.running, false, "Showable should be done running after delayed showNow");
            compare(show1.opacity, 1.0, "Showable should be at end of animation after delayed showNow");
        }
    }
}
