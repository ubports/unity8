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
import QMenuModel 0.1
import "../../../../qml/Panel/Indicators"

Item {
    id: testView
    width: units.gu(40)
    height: units.gu(70)

   DefaultIndicatorWidget {
        id: widget

        anchors {
            left: parent.left
            top: parent.top
        }

        menuModel: UnityMenuModel {}
        busName: "test"
        actionsObjectPath: "test"
        deviceMenuObjectPath: "test"

        rootMenuType: ""

        iconSize: units.gu(3.2)
        height: units.gu(3)

        rootActionState {
            icons: [ "image://theme/audio-volume-high", "image://theme/audio-volume-low" ]
            leftLabel: "left"
            rightLabel: "right"
        }
    }

    UT.UnityTestCase {
        name: "DefaultIndicatorWidget"
        when: windowShown

        function init() {
            widget.rootActionState.icons = [];
            widget.rootActionState.leftLabel = "";
            widget.rootActionState.rightLabel = "";
            wait(50);
        }

        function test_guRoundedWidth_data() {
            return [
                { tag: "empty", icons: [], leftLabel: "", rightLabel: "" },
                { tag: "1-icon-no-label", icons: [ "image://theme/audio-volume-high" ], leftLabel: "", rightLabel: "" },
                { tag: "2-icon-no-label", icons: [ "image://theme/audio-volume-high", "image://theme/audio-volume-low" ], leftLabel: "", rightLabel: "" },
                { tag: "no-icon-l-label", icons: [], leftLabel: "left", rightLabel: "" },
                { tag: "no-icon-lr-label", icons: [], leftLabel: "left", rightLabel: "right" },
                { tag: "1-icon-l-label", icons: [ "image://theme/audio-volume-high" ], leftLabel: "left", rightLabel: "" },
                { tag: "1-icon-lr-label", icons: [ "image://theme/audio-volume-high" ], leftLabel: "left", rightLabel: "right" },
                { tag: "2-icon-l-label", icons: [ "image://theme/audio-volume-high", "image://theme/audio-volume-low" ], leftLabel: "left", rightLabel: "" },
                { tag: "2-icon-lr-label", icons: [ "image://theme/audio-volume-high", "image://theme/audio-volume-low" ], leftLabel: "left", rightLabel: "right" }
            ];
        }

        function test_guRoundedWidth(data) {
            widget.rootActionState.icons = data.icons
            widget.rootActionState.leftLabel = data.leftLabel;
            widget.rootActionState.rightLabel = data.rightLabel;
            wait(50);

            compare(widget.width, guRoundUp(widget.width));
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
}
