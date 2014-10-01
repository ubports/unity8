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

        busName: "test"
        actionsObjectPath: "test"
        menuObjectPath: "test"

        rootMenuType: ""

        iconSize: units.gu(3.2)
        height: units.gu(3)
    }

    UT.UnityTestCase {
        name: "DefaultIndicatorWidget"
        when: windowShown

        function init() {
            widget.rootActionState.icons = [];
            widget.rootActionState.leftLabel = "";
            widget.rootActionState.rightLabel = "";
            waitForRendering(widget)
        }

        // FIXME: add tests
    }
}
