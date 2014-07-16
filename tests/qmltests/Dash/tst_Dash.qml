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
import "../../../qml/Dash"
import Ubuntu.Components 0.1
import Unity.Test 0.1 as UT

// TODO We don't have any tests for the overlay scope functionality.

Item {
    id: shell
    width: units.gu(40)
    height: units.gu(80)

    // BEGIN To reduce warnings
    // TODO I think it we should pass down these variables
    // as needed instead of hoping they will be globally around
    property var greeter: null
    property var panel: null
    // BEGIN To reduce warnings


    Dash {
        id: dash
        anchors.fill: parent
        showScopeOnLoaded: "MockScope2"
    }

    UT.UnityTestCase {
        name: "Dash"
        when: windowShown

        property var scopes

        Component.onCompleted: {
            var dashContent = findChild(dash, "dashContent");
            scopes = dashContent.scopes;
        }

        function init() {
            // clear and reload the scopes.
            scopes.clear();
            var dashContentList = findChild(dash, "dashContentList");
            verify(dashContentList != undefined);
            tryCompare(dashContentList, "count", 0);
            scopes.load();
        }

        function get_scope_data() {
            return [
                        { tag: "MockScope1", visualIndex: 0, shouldBeVisible: true },
                        { tag: "MockScope2", visualIndex: -1, shouldBeVisible: false },
                        { tag: "clickscope", visualIndex: 1, shouldBeVisible: true },
                        { tag: "MockScope5", visualIndex: 2, shouldBeVisible: true },
            ]
        }

        function test_show_scope_on_load_data() {
            return get_scope_data()
        }

        function test_show_scope_on_load(data) {
            if (data.shouldBeVisible == false) {
                console.log("Not testing " + data.tag + ": not visible");
                return;
            }
            var dashContentList = findChild(dash, "dashContentList");

            dash.showScopeOnLoaded = data.tag
            scopes.clear();
            tryCompare(dashContentList, "count", 0);
            scopes.load();
            tryCompare(scopes, "loaded", true);
            tryCompare(dashContentList, "count", 6);

            verify(dashContentList != undefined);
            tryCompare(dashContentList, "currentIndex", data.visualIndex);
        }
    }
}
