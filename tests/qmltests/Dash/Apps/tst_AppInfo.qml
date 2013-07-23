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
import Ubuntu.Components 0.1
import "../../../../Dash/Apps"
import Unity.Test 0.1 as UT

Item {
    width: units.gu(50)
    height: units.gu(40)

    // The component under test
    AppInfo {
        id: appInfo
        anchors.fill: parent
        icon: ""
        appName: "App Info"
        rating: 6
        rated: 120
        reviews: 8
    }

    UT.UnityTestCase {
        name: "RunningApplicationsGrid"
        when: windowShown

        function test_rated() {
            var rated = findChild(appInfo, "ratedLabel");
            compare(rated.text, "(120)");
        }

        function test_reviews() {
            var rated = findChild(appInfo, "reviewsLabel");
            compare(rated.text, i18n.tr("%n review", "%n reviews", 8));
        }
    }
}
