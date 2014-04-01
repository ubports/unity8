/*
 * Copyright (C) 2014 Canonical, Ltd.
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
import Unity.Test 0.1 as UT
import "../../../qml/Dash"
import "CardHelpers.js" as Helpers

Rectangle {
    id: root
    width: units.gu(80)
    height: units.gu(72)
    color: "#88FFFFFF"

    property string cardData: '
    {
      "art": "../../tests/qmltests/Dash/artwork/music-player-design.png",
      "mascot": "../../tests/qmltests/Dash/artwork/avatar.png",
      "title": "foo",
      "subtitle": "bar",
      "summary": "Lorem ipsum dolor sit amet, consectetur adipisicing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum."
    }'

//     property string artCardModel: '{ "components": { "art": "art" } }'
    property string artCardModel: '{ "components": { "art": "art", "title": "title" } }'

    CardTool {
        id: cardTool
        template: Helpers.update(JSON.parse(Helpers.defaultLayout), JSON.parse(artCardModel))['template'];
        components: Helpers.update(JSON.parse(Helpers.defaultLayout), JSON.parse(artCardModel))['components'];
        viewWidth: units.gu(48)
    }

    Repeater {
        id: cardRepeater
        model: 0
        Card {
            width: cardTool.cardWidth || implicitWidth
            height: cardTool.cardHeight || implicitHeight

            template: cardTool.template
            components: cardTool.components
            cardData: Helpers.mapData(root.cardData, components)
        }
    }

    UT.UnityTestCase {
        id: testCase
        name: "CardBenchmark"

        when: windowShown

        function benchmark_time() {
            cardRepeater.model = 1
            cardRepeater.model = 0
        }
    }
}
