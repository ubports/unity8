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

    property string defaultLayout: '
    {
      "schema-version": 1,
      "template": {
        "category-layout": "grid",
        "card-layout": "vertical",
        "card-size": "medium",
        "overlay-mode": null,
        "collapsed-rows": 2
      },
      "components": {
        "title": null,
        "art": {
            "aspect-ratio": 1.0,
            "fill-mode": "crop"
        },
        "subtitle": null,
        "mascot": null,
        "emblem": null,
        "old-price": null,
        "price": null,
        "alt-price": null,
        "rating": {
          "type": "stars",
          "range": [0, 5],
          "full": "image://theme/rating-star-full",
          "half": "image://theme/rating-star-half",
          "empty": "image://theme/rating-star-empty"
        },
        "alt-rating": null,
        "summary": null
      },
      "resources": {}
    }'

    property string fullMapping: '
    {
      "title": "title",
      "art": "art",
      "subtitle": "subtitle",
      "mascot": "mascot",
      "summary": "summary"
    }'

    property var cardsModel: [
        {
            "name": "Art, header, summary - vertical",
            "layout": { "components": JSON.parse(fullMapping) }
        },
        {
            "name": "Art, header, summary - vertical, small",
            "layout": { "template": { "card-size": "small" }, "components": JSON.parse(fullMapping) }
        },
        {
            "name": "Art, header, summary - vertical, large",
            "layout": { "template": { "card-size": "large" }, "components": JSON.parse(fullMapping) }
        },
        {
            "name": "Header title only - horizontal",
            "layout": { "template": { "card-layout": "horizontal" },
                        "components": { "title": "title" } }
        },
    ]

    CardTool {
        id: cardTool

        template: Helpers.update(JSON.parse(root.defaultLayout), Helpers.tryParse(layoutArea.text, layoutError))['template'];
        components: Helpers.update(JSON.parse(root.defaultLayout), Helpers.tryParse(layoutArea.text, layoutError))['components'];
    }

    Column {
        width: units.gu(38)
        anchors { left: parent.left; top: parent.top; margins: units.gu(1) }

        Repeater {
            model: [
                { label: "Card width", value: cardTool.cardWidth && cardTool.cardWidth / units.gu(1) },
                { label: "Card height", value: cardTool.cardHeight && cardTool.cardHeight / units.gu(1) },
            ]

            delegate: Row {
                anchors { left: parent.left; right: parent.right; margins: units.gu(3) }

                Label {
                    height: units.gu(5)
                    width: units.gu(25)
                    text: modelData.label
                    verticalAlignment: Text.AlignVCenter
                }

                Label {
                    height: units.gu(5)
                    text: modelData.value || "undefined"
                    verticalAlignment: Text.AlignVCenter
                }
            }
        }

        Card {
            template: cardTool.template;
            components: cardTool.components;
            cardData: Helpers.mapData(dataArea.text, components, dataError)

            width: cardTool.cardWidth || implicitWidth
            height: cardTool.cardHeight || implicitHeight

            clip: true

            Rectangle {
                anchors.fill: parent
                color: "transparent"
                border.width: 1
                border.color: "green"
            }
        }
    }

    Rectangle {
        anchors { top: parent.top; bottom: parent.bottom; right: parent.right}
        width: units.gu(40)
        color: "lightgrey"

        Column {
            anchors { fill: parent; margins: units.gu(1) }
            spacing: units.gu(1)

            OptionSelector {
                id: selector
                model: cardsModel
                delegate: OptionSelectorDelegate { text: modelData.name }
                onSelectedIndexChanged: updateAreas()
                Component.onCompleted: updateAreas()

                function updateAreas() {
                    var element = cardsModel[selectedIndex];
                    if (element) {
                        layoutArea.text = JSON.stringify(element.layout, undefined, 2) || "{}";
                    } else {
                        layoutArea.text = "";
                    }
                }
            }

            OptionSelector {
                id: layoutSelector
                model: [
                    { label: "Grid", layout: "grid" },
                    { label: "Organic Grid", layout: "organic-grid" },
                    { label: "Horizontal Journal", layout: "journal" },
                    { label: "Vertical Journal", layout: "vertical-journal" },
                ]
                delegate: OptionSelectorDelegate { text: modelData.label }
                onSelectedIndexChanged: {
                    var element = model[selectedIndex];
                    if (element && cardTool.template["category-layout"] !== element.layout) {
                        var current = JSON.parse(layoutArea.text);
                        var update = { "template": { "category-layout": element.layout }}
                        layoutArea.text = JSON.stringify(Helpers.update(current, update), undefined, 2) || "{}";
                    }
                }
            }

            TextArea {
                id: layoutArea
                anchors { left: parent.left; right: parent.right }
                height: units.gu(25)
            }

            Label {
                id: layoutError
                anchors { left: parent.left; right: parent.right }
                height: units.gu(4)
                color: "orange"
            }

            TextArea {
                id: dataArea
                anchors { left: parent.left; right: parent.right }
                height: units.gu(25)
                text: JSON.stringify(cardTool.priv.cardData, undefined, 2)
            }

            Label {
                id: dataError
                anchors { left: parent.left; right: parent.right }
                height: units.gu(4)
                color: "orange"
            }
        }

        Connections {
            target: cardTool
            onTemplateChanged: {
                switch(cardTool.template["category-layout"]) {
                    case "organic-grid": layoutSelector.selectedIndex = 1; break;
                    case "journal": layoutSelector.selectedIndex = 2; break;
                    case "vertical-journal": layoutSelector.selectedIndex = 3; break;
                    case "grid":
                    default: layoutSelector.selectedIndex = 0; break;
                }
            }
        }
    }

    UT.UnityTestCase {
        id: testCase
        name: "Card"

        when: windowShown

        function cleanup() {
            selector.selectedIndex = -1;
            layoutSelector.selectedIndex = -1;
        }

        function test_card_size_data() {
            return [
                { tag: "Medium", width: units.gu(18.5), height: undefined, index: 0 },
                { tag: "Small", width: units.gu(12), height: undefined, index: 1 },
                { tag: "Large", width: units.gu(38), height: undefined, index: 2 },
                { tag: "Horizontal", width: units.gu(38), height: undefined, index: 3 },
                { tag: "Journal", width: undefined, height: units.gu(20), size: 20, index: 0, layout_index: 2 },
                { tag: "OversizedJournal", width: undefined, height: units.gu(18.5), size: 40, index: 0, layout_index: 2 },
            ]
        }

        function test_card_size(data) {
            selector.selectedIndex = data.index;
            if (data.hasOwnProperty("layout_index")) {
                layoutSelector.selectedIndex = data.layout_index;
            }

            if (data.hasOwnProperty("size")) {
                cardTool.template['card-size'] = data.size;
                cardTool.templateChanged();
            }

            if (data.hasOwnProperty("width")) {
                tryCompare(cardTool, "cardWidth", data.width);
            }

            if (data.hasOwnProperty("height")) {
                tryCompare(cardTool, "cardHeight", data.height);
            }
        }
    }
}
