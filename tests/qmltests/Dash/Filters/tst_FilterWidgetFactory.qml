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
import "../../../../qml/Dash/Filters"
import Unity.Test 0.1 as UT
import Unity 0.2
import Ubuntu.Components 1.3

Rectangle {
    id: root
    width: units.gu(60)
    height: units.gu(80)
    color: theme.palette.selected.background

    FilterWidgetFactory {
        id: factory
        anchors {
            left: parent.left
            right: parent.right
        }
    }

    UT.UnityTestCase {
        name: "FilterWidgetFactory"
        when: windowShown

        function test_mapping_data() {
            return [
                { tag: "OptionSelector", type: Filters.OptionSelectorFilter, source: "FilterOptionSelector.qml" }
            ];
        }

        function test_mapping(data) {
            factory.widgetData = {};
            factory.widgetType = data.type;

            verify((String(factory.source)).indexOf(data.source) != -1);
        }
    }
}
