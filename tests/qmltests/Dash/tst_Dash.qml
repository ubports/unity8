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
        showLensOnLoaded: "MockLens2"
    }

    LensDelegateMapper {
        id: lens_delegate_mapper
        lensDelegateMapping: {
            "MockLens1": "../tests/qmltests/Dash/qml/fake_lensView1.qml",
            "MockLens2": "../tests/qmltests/Dash/qml/fake_lensView2.qml",
            "MockLens3": "../tests/qmltests/Dash/qml/fake_lensView3.qml",
            "MockLens4": "../tests/qmltests/Dash/qml/fake_lensView4.qml"
        }
        genericLens: "../tests/qmltests/Dash/qml/fake_generic_lensView.qml"
    }

    UT.UnityTestCase {
        name: "Dash"
        when: windowShown

        property var lenses

        Component.onCompleted: {
            var dashContent = findChild(dash, "dashContent");
            dashContent.lens_mapper = lens_delegate_mapper;
            lenses = dashContent.lenses;
        }

        function init() {
            // clear and reload the lenses.
            lenses.clear();
            var dashContentList = findChild(dash, "dashContentList");
            verify(dashContentList != undefined);
            tryCompare(dashContentList, "count", 0);
            lenses.load();
        }

        function get_lens_data() {
            return [
                        { tag: "MockLens1", visual_index: 0, should_be_visible: true },
                        { tag: "MockLens2", visual_index: -1, should_be_visible: false },
                        { tag: "MockLens3", visual_index: 1, should_be_visible: true },
                        { tag: "MockLens4", visual_index: 2, should_be_visible: true },
                        { tag: "MockLens5", visual_index: 3, should_be_visible: true },
            ]
        }

        function test_set_current_lens_data() {
            return get_lens_data()
        }

        function test_set_current_lens(data) {
            // wait for lenses to load
            tryCompare(lenses, "loaded", true);

            var dashbar = findChild(dash, "dashbar");
            verify(dashbar != undefined)
            var dashContent = findChild(dash, "dashContent");
            var current_index = dashContent.currentIndex;

            dash.setCurrentLens(data.tag, true, false);
            compare(dashContent.currentIndex, data.should_be_visible ? data.visual_index : current_index);
            compare(dashbar.currentIndex, data.should_be_visible ? data.visual_index : current_index);
        }

        function test_show_lens_on_load_data() {
            return get_lens_data()
        }

        function test_show_lens_on_load(data) {
            if (data.should_be_visible == false) {
                console.log("Not testing " + data.tag + ": not visible");
                return;
            }
            dash.showLensOnLoaded = data.tag

            var dashContentList = findChild(dash, "dashContentList");
            verify(dashContentList != undefined);
            tryCompare(dashContentList, "currentIndex", data.visual_index);
        }

        function test_dash_bar_set_index_connection_data() {
            return get_lens_data()
        }

        function test_dash_bar_set_index_connection(data) {
            if (data.should_be_visible == false) {
                console.log("Not testing " + data.tag + ": not visible");
                return;
            }
            // wait for lenses to load
            tryCompare(lenses, "loaded", true);

            var dashbar = findChild(dash, "dashbar");
            verify(dashbar != undefined)
            var dashContent = findChild(dash, "dashContent");
            var current_index = dashContent.currentIndex;

            dashbar.itemSelected(data.visual_index);
            compare(dashContent.currentIndex, data.should_be_visible ? data.visual_index : current_index);
        }
    }
}
