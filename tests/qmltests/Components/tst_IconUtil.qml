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
import "../../../Components/IconUtil.js" as IconUtil

TestCase {
    id: root
    name: "IconUtil"

    function test_from_gicon_data() {
        return [ {in: ". GThemedIcon one", out: "image://theme/one"},
                 {in: ". GThemedIcon one two", out: "image://theme/one,two"},
                 {in: ". UnityProtocolAnnotatedIcon %7B'base-icon':%20%3C'.%20GThemedIcon%20one%20two'%3E%7D", out: "image://theme/one,two"},
                 {in: "icon.test_0-name", out: "image://theme/icon.test_0-name"},
                 {in: "?^713]p", out: "?^713]p"},
               ]
    }

    function test_from_gicon(data) {
        var out = IconUtil.from_gicon(data.in)
        compare(out, data.out)
    }
}
