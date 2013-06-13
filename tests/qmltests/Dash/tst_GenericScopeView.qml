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
import Unity 0.1
import ".."
import "../../../Dash"
import Ubuntu.Components 0.1
import Unity.Test 0.1 as UT

Item {
    width: units.gu(120)
    height: units.gu(80)

    Scopes {
        id: scopes
    }

    GenericScopeView {
        id: genericScopeView
        anchors.fill: parent

        UT.UnityTestCase {
            name: "GenericScopeView"
            when: scopes.loaded

            function init() {
                genericScopeView.scope = scopes.get(0)
            }

            function test_isCurrent() {
                var pageHeader = findChild(genericScopeView, "pageHeader");
                genericScopeView.isCurrent = true
                pageHeader.searchQuery = "test"
                genericScopeView.isCurrent = false
                tryCompare(pageHeader, "searchQuery", "")
            }
        }
    }
}
