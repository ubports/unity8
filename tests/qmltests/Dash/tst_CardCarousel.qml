/*
 * Copyright (C) 2013 Canonical, Ltd.
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
import Ubuntu.Components 1.3
import Unity.Test 0.1 as UT
import "../../../qml/Dash"
import "CardHelpers.js" as Helpers

Rectangle {
    id: root
    width: units.gu(80)
    height: units.gu(72)
    color: "#88FFFFFF"

    property var overlaidTemplate: {"card-layout":"vertical", "card-size":"small", "category-layout":"carousel", "overlay": true }
    property var nonOverlaidTemplate: {"card-layout":"vertical", "card-size":"small", "category-layout":"carousel" }

    CardTool {
        id: cTool
        count: 10
        objectName: "cardTool"
        template:  nonOverlaidTemplate
        components: {"art":{"aspect-ratio":1.6,"field":"art"}, "title":{"field":"title"}, "attributes":{}}
        viewWidth: parent.width
    }

    ListModel {
        id: lModel

        Component.onCompleted: {
            cTool.templateChanged();
            for (var i = 0; i < cTool.count; ++i) {
                lModel.append( { title: "fqg\nfqg", art: Qt.resolvedUrl("artwork/music-player-design.png").toString() } );
            }
        }
    }

    CardCarousel {
        id: cardCarousel
        cardTool: cTool
        width: parent.width
        height: expandedHeight
        model: lModel

        Rectangle {
            color: "red"
            opacity: 0.2
            anchors.fill: parent
        }
    }

    UT.UnityTestCase {
        id: testCase
        name: "CardCarousel"

        when: windowShown

        function test_non_overlaid_header_layout() {
            // When the header is non overlaid
            // we grow down to accomodate the header but the y of the list is the same
            var listView = findChild(cardCarousel, "listView");

            cTool.template = overlaidTemplate;
            var yPos = listView.y;
            var height = cardCarousel.height;

            cTool.template = nonOverlaidTemplate;
            compare(listView.y, yPos);
            compare(cardCarousel.height, height + cTool.headerHeight);
        }
    }
}
