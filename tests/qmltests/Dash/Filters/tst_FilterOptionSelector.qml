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

    property var singleSelectionWidgetData

    ListModel {
        id: optionsSingleSelect
        ListElement {
            label: "A"
            checked: false
        }
        ListElement {
            label: "B"
            checked: false
        }
        ListElement {
            label: "C"
            checked: false
        }

        function setChecked(index, checked) {
            for (var i = 0; i < optionsSingleSelect.count; ++i)
                optionsSingleSelect.setProperty(i, "checked", false);
            optionsSingleSelect.setProperty(index, "checked", checked);
        }
    }

    Component.onCompleted: {
        singleSelectionWidgetData = { label: "Hola", options: optionsSingleSelect }
    }

    FilterWidgetFactory {
        id: factory
        widgetId: "testOptionSelectorFilter"
        widgetType: Filters.OptionSelectorFilter
        widgetData: singleSelectionWidgetData
        anchors {
            left: parent.left
            right: parent.right
        }
    }

    UT.UnityTestCase {
        name: "FilterOptionSelector"
        when: windowShown

        function test_optionSelector() {
            var expandingItem = findChild(factory, "expandingItem");
            // Open the selector
            mouseClick(factory);
            // wait for it to stop growing
            tryCompare(factory, "implicitHeight", expandingItem.expandedHeight);

            // Check the first option
            var option0 = findChild(factory, "testOptionSelectorFilterlabel0");
            mouseClick(option0);
            verify(optionsSingleSelect.get(0).checked);

            // Check the second option
            var option1 = findChild(factory, "testOptionSelectorFilterlabel1");
            mouseClick(option1);
            verify(!optionsSingleSelect.get(0).checked);
            verify(optionsSingleSelect.get(1).checked);

            // Uncheck the second option
            mouseClick(option1);
            verify(!optionsSingleSelect.get(1).checked);
        }
    }
}
