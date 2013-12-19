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
import "../../../qml/Hud"
import Unity.Test 0.1 as UT

Rectangle {
    width: 600
    height: 600
    color: "black"
    Column {
        anchors.fill: parent
        Repeater {
            model: test.test_highlightedText_data().length
            Result {
                width: parent.width
                height: units.gu(4)
                nameText: test.test_highlightedText_data()[index].text
                nameHighlights: test.test_highlightedText_data()[index].highlights
            }
        }
    }

    UT.UnityTestCase {
        name: "Result"
        id: test

        Result {
            id: result
        }

        function test_highlightedText_data() {
            return [
                    {
                     text: "Copy",
                     highlights: [],
                     result: "Copy"
                    },
                    {
                     text: "Copy",
                     highlights: [0, 0],
                     result: "<font color=\"#ffffff\">C</font>opy"
                    },
                    {
                     text: "Copy",
                     highlights: [1, 1],
                     result: "C<font color=\"#ffffff\">o</font>py"
                    },
                    {
                     text: "Pastel",
                     highlights: [1, 1, 3, 4],
                     result: "P<font color=\"#ffffff\">a</font>s<font color=\"#ffffff\">te</font>l"
                    },
                    {
                     text: "Pastel",
                     highlights: [1, 1, 3, 5],
                     result: "P<font color=\"#ffffff\">a</font>s<font color=\"#ffffff\">tel</font>"
                    },
                    {
                     text: "Pastel",
                     highlights: [0, 0, 3, 5],
                     result: "<font color=\"#ffffff\">P</font>as<font color=\"#ffffff\">tel</font>"
                    },
                    {
                     text: "Pastel",
                     highlights: [5, 5],
                     result: "Paste<font color=\"#ffffff\">l</font>"
                    },
                    {
                     text: "Two Words",
                     highlights: [1, 2, 5, 5],
                     result: "T<font color=\"#ffffff\">wo</font> W<font color=\"#ffffff\">o</font>rds"
                    }
                ]
        }

        function test_highlightedText(data) {
            var hText = result.highlightedText(data.text, data.highlights);
            compare(hText, data.result);
        }
    }
}
