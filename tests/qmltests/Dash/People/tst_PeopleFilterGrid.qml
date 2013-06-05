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
import "../.."
import "../../../../Dash/People"
import Ubuntu.Components 0.1
import Unity.Test 0.1 as UT

Item {
    id: root
    width: units.gu(120)
    height: units.gu(40)

    PeopleFilterGrid {
        id: peopleFilterGrid
        anchors.fill: parent
        model: mockModel
    }

    SignalSpy {
        id: signalSpy
        target: peopleFilterGrid
        signalName: "clicked"
    }

    ListModel {
        id: mockModel

        ListElement {
            column_0: 'user://001'
            column_1: "gtk-apply"
            column_2: ""
            column_3: ""
            column_4: "User 1"
            column_5: "Text 1"
        }

        ListElement {
            column_0: 'user://002'
            column_1: "gtk-apply"
            column_2: ""
            column_3: ""
            column_4: "User 2"
            column_5: "Text 2"
        }

        ListElement {
            column_0: 'user://003'
            column_1: "gtk-apply"
            column_2: ""
            column_3: ""
            column_4: "User 3"
            column_5: "Text 3"
        }

        ListElement {
            column_0: 'user://004'
            column_1: "gtk-apply"
            column_2: ""
            column_3: ""
            column_4: "User 4"
            column_5: "Text 4"
        }

        ListElement {
            column_0: 'user://005'
            column_1: "gtk-apply"
            column_2: ""
            column_3: ""
            column_4: "User 5"
            column_5: "Text 5"
        }

    }

    UT.UnityTestCase {
        id: testCase
        name: "DashPeopleFilterGrid"
        when: windowShown

        function init() {
        }

        function test_clickCell_data() {
            return [
                {
                    x: peopleFilterGrid.minimumHorizontalSpacing+peopleFilterGrid.cellWidth/2,
                    y: peopleFilterGrid.verticalSpacing+peopleFilterGrid.cellHeight/2,
                    index: 0,
                    uri: "user://001"
                },
                {
                    x: 2*peopleFilterGrid.minimumHorizontalSpacing+peopleFilterGrid.cellWidth+peopleFilterGrid.cellWidth/2,
                    y: peopleFilterGrid.verticalSpacing+peopleFilterGrid.cellHeight/2,
                    index: 1,
                    uri: "user://002"
                },
                {
                    x: 3*peopleFilterGrid.minimumHorizontalSpacing+2*peopleFilterGrid.cellWidth+peopleFilterGrid.cellWidth/2,
                    y: peopleFilterGrid.verticalSpacing+peopleFilterGrid.cellHeight/2,
                    index: 2,
                    uri: "user://003"
                },
                {
                    x: peopleFilterGrid.minimumHorizontalSpacing+peopleFilterGrid.cellWidth/2,
                    y: 2*peopleFilterGrid.verticalSpacing+peopleFilterGrid.cellHeight+peopleFilterGrid.cellHeight/2,
                    index: 3,
                    uri: "user://004"
                },
                {
                    x: 2*peopleFilterGrid.minimumHorizontalSpacing+peopleFilterGrid.cellWidth+peopleFilterGrid.cellWidth/2,
                    y: 2*peopleFilterGrid.verticalSpacing+peopleFilterGrid.cellHeight+peopleFilterGrid.cellHeight/2,
                    index: 4,
                    uri: "user://005"
                },
            ]
        }

        function test_columns() {
            compare(peopleFilterGrid.columns,3)
        }

        function test_clickCell(data) {
            tryCompare(peopleFilterGrid, "flicking", false)
            tryCompare(peopleFilterGrid, "moving", false)
            signalSpy.clear()
            wait(peopleFilterGrid.pressDelay > 0 ? peopleFilterGrid.pressDelay : 5)
            mouseClick(peopleFilterGrid, data.x, data.y)
            tryCompare(peopleFilterGrid, "flicking", false)
            tryCompare(peopleFilterGrid, "moving", false)
            compare(signalSpy.count, 1)
            compare(signalSpy.signalArguments.length, 1, "signalArguments.length != 1")
            compare(signalSpy.signalArguments[0][0], data.index)
            compare(signalSpy.signalArguments[0][1]["uri"], data.uri)
        }

    }
}
