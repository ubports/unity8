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
import "../../../Dash"
import Ubuntu.Components 0.1
import Unity.Test 0.1 as UT

Item {
    id: shell
    width: units.gu(40)
    height: units.gu(80)

    property ListModel searchHistory : ListModel {}

    Dash {
        id: dash
        anchors.fill: parent
        showScopeOnLoaded: "MockScope2"
    }

    ScopeDelegateMapper {
        id: scopeDelegateMapper
        scopeDelegateMapping: {
            "MockScope1": "../tests/qmltests/Dash/qml/fake_scopeView1.qml",
            "MockScope2": "../tests/qmltests/Dash/qml/fake_scopeView2.qml",
            "home.scope": "../tests/qmltests/Dash/qml/fake_scopeView3.qml",
            "applications.scope": "../tests/qmltests/Dash/qml/fake_scopeView4.qml"
        }
        genericScope: "../tests/qmltests/Dash/qml/fake_generic_scopeView.qml"
    }

    UT.UnityTestCase {
        name: "Dash"
        when: windowShown

        property var scopes

        Component.onCompleted: {
            var dashContent = findChild(dash, "dashContent");
            dashContent.scopeMapper = scopeDelegateMapper;
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
                        { tag: "home.scope", visualIndex: 1, shouldBeVisible: true },
                        { tag: "applications.scope", visualIndex: 2, shouldBeVisible: true },
                        { tag: "MockScope5", visualIndex: 3, shouldBeVisible: true },
            ]
        }

        function test_set_current_scope_data() {
            return get_scope_data()
        }

        function test_set_current_scope(data) {
            // wait for scopes to load
            tryCompare(scopes, "loaded", true);

            var dashbar = findChild(dash, "dashbar");
            verify(dashbar != undefined)
            var dashContent = findChild(dash, "dashContent");
            var current_index = dashContent.currentIndex;

            dash.setCurrentScope(data.tag, true /* animate */, false /* reset */);
            compare(dashContent.currentIndex, data.shouldBeVisible ? data.visualIndex : current_index);
            compare(dashbar.currentIndex, data.shouldBeVisible ? data.visualIndex : current_index);
        }

        function test_show_scope_on_load_data() {
            return get_scope_data()
        }

        function test_show_scope_on_load(data) {
            if (data.shouldBeVisible == false) {
                console.log("Not testing " + data.tag + ": not visible");
                return;
            }
            dash.showScopeOnLoaded = data.tag
            scopes.clear();
            scopes.load();

            var dashContentList = findChild(dash, "dashContentList");
            verify(dashContentList != undefined);
            tryCompare(dashContentList, "currentIndex", data.visualIndex);
        }

        function test_dash_bar_set_index_connection_data() {
            return get_scope_data()
        }

        function test_dash_bar_set_index_connection(data) {
            if (data.shouldBeVisible == false) {
                console.log("Not testing " + data.tag + ": not visible");
                return;
            }
            // wait for scopes to load
            tryCompare(scopes, "loaded", true);

            var dashbar = findChild(dash, "dashbar");
            verify(dashbar != undefined)
            var dashContent = findChild(dash, "dashContent");
            var current_index = dashContent.currentIndex;

            dashbar.itemSelected(data.visualIndex);
            compare(dashContent.currentIndex, data.shouldBeVisible ? data.visualIndex : current_index);
        }
    }
}
