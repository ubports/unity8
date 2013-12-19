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
import "../../../qml/SideStage"
import Ubuntu.Components 0.1

UT.UnityTestCase {
    name: "SideStage"

    SideStage {
        id: sideStage
        width: units.gu(30)
        height: units.gu(30)
        handleExpanded: sideStageRevealer.pressed
        handleSizeCollapsed: units.gu(2)
        handleSizeExpanded: units.gu(5)
    }

    function test_handle_data() {
        return [
            {tag: "expanded", expanded: true},
            {tag: "collapsed", expanded: false}
        ]
    }

    function test_handle(data) {
        sideStage.handleExpanded = data.expanded

        if (data.expanded) {
            tryCompare(findChild(sideStage, "sideStageHandle"), "width", sideStage.handleSizeExpanded);
        } else {
            tryCompare(findChild(sideStage, "sideStageHandle"), "width", sideStage.handleSizeCollapsed);
        }
    }
}
