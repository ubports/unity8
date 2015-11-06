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

import QtQuick 2.4
import QtTest 1.0
import Ubuntu.Components 1.3
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

    PreviewComment {
        id: previewComment
        anchors.left: parent.left
        anchors.right: parent.right
        widgetData: comment
        widgetId: "previewComment"
    }

    UT.UnityTestCase {
        name: "PreviewCommentTest"
        when: windowShown

        function init() {
            previewComment.widgetData = comment;
        }

        function test_AnchorsNoAvatar() {
            var column = findChild(previewComment, "column");
            var avatar = findChild(previewComment, "avatar");

            compare(previewComment.widgetData, comment);
            compare(avatar.visible, true);
            compare(column.anchors.left, avatar.anchors.right);

            previewComment.widgetData = commentNoImage;
            tryCompare(avatar, "visible", false);
            compare(column.anchors.left, previewComment.anchors.left);
        }

        function test_OptionalSubtitle() {
            var subtitle = findChild(previewComment, "subtitle");
            previewComment.widgetData = commentNoSubtitle;
            tryCompare(subtitle, "visible", false);
        }
    }
}
