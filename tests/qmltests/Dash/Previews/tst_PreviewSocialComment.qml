/*
 * Copyright 2015 Canonical Ltd.
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
import Ubuntu.Components 1.1
import "../../../../qml/Dash/Previews"
import Unity.Test 0.1 as UT

Rectangle {
    id: root
    width: units.gu(40)
    height: units.gu(80)
    color: Theme.palette.selected.background

    property var comment: {
        "author": "Claire Thompson",
        "subtitle": "28/04/2015 3:48pm",
        "comment": "Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum.",
        "source": "../../graphics/avatars/amanda@12.png"
    }

    property var commentNoImage: {
        "author": "Claire Thompson",
        "subtitle": "28/04/2015 3:48pm",
        "comment": "Been quite a while since I really liked one.",
        "source": ""
    }

    property var commentNoSubtitle: {
        "author": "Claire Thompson",
        "comment": "Been quite a while since I really liked one.",
        "source": "../../graphics/avatars/amanda@12.png"
    }

    PreviewSocialComment {
        id: previewCommentInput
        anchors.left: parent.left
        anchors.right: parent.right
        widgetData: comment
        widgetId: "previewSocialComment"
    }

    UT.UnityTestCase {
        name: "PreviewSocialCommentTest"
        when: windowShown

        function init() {
            previewCommentInput.widgetData = comment;
        }

        function test_AnchorsNoAvatar() {
            var column = findChild(previewCommentInput, "column");
            var avatar = findChild(previewCommentInput, "avatar");

            compare(previewCommentInput.widgetData, comment);
            compare(avatar.visible, true);
            compare(column.anchors.left, avatar.anchors.right);

            previewCommentInput.widgetData = commentNoImage;
            tryCompare(avatar, "visible", false);
            compare(column.anchors.left, previewCommentInput.anchors.left);
        }

        function test_OptionalSubtitle() {
            var subtitle = findChild(previewCommentInput, "subtitle");
            previewCommentInput.widgetData = commentNoSubtitle;
            tryCompare(subtitle, "visible", false);
        }
    }
}
