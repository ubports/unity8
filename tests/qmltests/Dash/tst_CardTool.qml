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

    property var cardsModel: [
        {
            "name": "Art, header, summary",
            "layout": { "components": JSON.parse(Helpers.fullMapping) }
        },
        {
            "name": "Header, summary",
            "layout": { "components": Helpers.update(JSON.parse(Helpers.fullMapping), { "art": undefined }) }
        },
        {
            "name": "Art, header",
            "layout": { "components": Helpers.update(JSON.parse(Helpers.fullMapping), { "summary": undefined }) }
        },
        {
            "name": "Header only",
            "layout": { "components": Helpers.update(JSON.parse(Helpers.fullMapping), { "art": undefined, "summary": undefined }) }
        },
        {
            "name": "Header title only",
            "layout": { "components": { "title": "title" } }
        },
        {
            "name": "Header title and subtitle",
            "layout": { "components": { "title": "title", "subtitle": "subtitle" } }
        },
        {
            "name": "Header title and mascot",
            "layout": { "components": { "title": "title", "mascot": "mascot" } }
        },
        {
            "name": "Art, header, summary - small",
            "layout": { "template": { "card-size": "small" }, "components": JSON.parse(Helpers.fullMapping) }
        },
        {
            "name": "Art, header, summary - large",
            "layout": { "template": { "card-size": "large" }, "components": JSON.parse(Helpers.fullMapping) }
        },
        {
            "name": "Art, header, summary - horizontal",
            "layout": { "template": { "card-layout": "horizontal" }, "components": JSON.parse(Helpers.fullMapping) }
        },
        {
            "name": "Art, header - portrait",
            "layout": { "components": Helpers.update(JSON.parse(Helpers.fullMapping), { "art": {"aspect-ratio": 0.5, "summary": undefined }}) }
        },
        {
            "name": "Title - vertical",
            "layout": { "template": { "card-layout": "vertical" }, "components": { "title": "title" } }
        },
        {
            "name": "Title - horizontal",
            "layout": { "template": { "card-layout": "horizontal" }, "components": { "title": "title" } }
        },
        {
            "name": "Title, subtitle - vertical",
            "layout": { "template": { "card-layout": "vertical" }, "components": { "title": "title", "subtitle": "subtitle" } }
        },
        {
            "name": "Title, attributes - horizontal",
            "layout": { "template": { "card-layout": "horizontal" }, "components": { "title": "title", "attributes": "attributes" } }
        },
    ]

    CardTool {
        id: cardTool

        count: 8
        template: Helpers.update(JSON.parse(Helpers.defaultLayout), Helpers.tryParse(layoutArea.text, layoutError))['template'];
        components: Helpers.update(JSON.parse(Helpers.defaultLayout), Helpers.tryParse(layoutArea.text, layoutError))['components'];
        viewWidth: units.gu(Math.round(widthSlider.value))
    }

    Column {
        id: column
        width: units.gu(38)
        anchors { left: parent.left; top: parent.top; margins: units.gu(1) }

        Repeater {
            model: [
                { label: "View width", value: cardTool.viewWidth && cardTool.viewWidth / units.gu(1) },
                { label: "Card width", value: cardTool.cardWidth !== -1 ? cardTool.cardWidth / units.gu(1) : undefined },
                { label: "Card height", value: cardTool.cardHeight !== -1 ? cardTool.cardHeight / units.gu(1) : undefined },
            ]

            delegate: Row {
                anchors { left: column.left; right: column.right; margins: units.gu(3) }

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
                    { label: "Carousel", layout: "carousel" },
                    { label: "Horizontal List", layout: "horizontal-list" },
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

            Label {
                anchors { left: parent.left; right: parent.right }
                height: units.gu(3)
                verticalAlignment: Text.AlignBottom
                text: "View width:"
            }

            Slider {
                id: widthSlider
                minimumValue: 30
                maximumValue: 140
                live: true
                value: 40
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
                text: JSON.stringify(testCase.internalCard.cardData, undefined, 2)
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
                    case "carousel": layoutSelector.selectedIndex = 4; break;
                    case "horizontal-list": layoutSelector.selectedIndex = 5; break;
                    case "grid":
                    default: layoutSelector.selectedIndex = 0; break;
                }
            }
        }
    }

    UT.UnityTestCase {
        id: testCase
        name: "CardTool"

        property var internalCard: findChild(cardTool, "cardToolCard")

        when: windowShown

        function init() {
            verify(typeof testCase.internalCard === "object", "Couldn't find internal card object.");
        }

        function cleanup() {
            selector.selectedIndex = -1;
            layoutSelector.selectedIndex = -1;
        }

        function test_card_size_data() {
            return [
                { tag: "Medium", width: units.gu(18), height: function() { return internalCard ? internalCard.height : 0 }, index: 0 },
                { tag: "No art", width: units.gu(18), height: function() { return internalCard ? internalCard.height : 0 }, index: 1 },
                { tag: "No summary", width: units.gu(18), height: function() { return internalCard ? internalCard.height : 0 }, index: 2 },
                { tag: "Just header", width: units.gu(18), height: function() { return internalCard ? internalCard.height : 0 }, index: 3 },
                { tag: "Just title", width: units.gu(18), height: function() { return internalCard ? internalCard.height : 0 }, index: 4 },
                { tag: "Title and subtitle", width: units.gu(18), height: function() { return internalCard ? internalCard.height : 0 }, index: 5 },
                { tag: "Title and mascot", width: units.gu(18), height: function() { return internalCard ? internalCard.height : 0 }, index: 6 },
                { tag: "Small", width: units.gu(12), height: function() { return internalCard ? internalCard.height : 0 }, index: 7 },
                { tag: "Large", width: units.gu(38), height: function() { return internalCard ? internalCard.height : 0 }, index: 8 },
                { tag: "Horizontal", width: units.gu(38), height: function() { return internalCard ? internalCard.height : 0 }, index: 9 },
                { tag: "OrganicGrid", width: -1, height: -1, index: 0, layout_index: 1},
                { tag: "Journal", width: -1, height: units.gu(20), size: 20, index: 0, layout_index: 2 },
                { tag: "OversizedJournal", width: -1, height: units.gu(18.5), size: 40, index: 0, layout_index: 2 },
                { tag: "VerticalJournal", width: units.gu(18), height: -1, index: 0, layout_index: 3 },
                { tag: "SmallCarousel", width: units.gu(18), height: units.gu(18), viewWidth: 30, index: 0, layout_index: 4},
                { tag: "MediumCarousel", width: units.gu(22), height: units.gu(22), viewWidth: 84, index: 0, layout_index: 4},
                { tag: "LargeCarousel", width: units.gu(26), height: units.gu(26), viewWidth: 140, index: 0, layout_index: 4},
                { tag: "PortraitCarousel", width: units.gu(22), height: units.gu(44), viewWidth: 84, index: 10, layout_index: 4},
                { tag: "SmallHorizontalList", width: units.gu(18),
                  height: function() { return internalCard ? internalCard.height : 0 },
                  viewWidth: 30, index: 0, layout_index: 5 },
                { tag: "MediumHorizontalList", width: units.gu(22),
                  height: function() { return internalCard ? internalCard.height : 0 },
                  viewWidth: 84, index: 0, layout_index: 5 },
                { tag: "LargeHorizontalList", width: units.gu(26),
                  height: function() { return internalCard ? internalCard.height : 0 },
                  viewWidth: 140, index: 0, layout_index: 5 },
                { tag: "PortraitHorizontalList", width: units.gu(22),
                  height: function() { return internalCard ? internalCard.height : 0 },
                  viewWidth: 84, index: 10, layout_index: 5 },
            ]
        }

        function test_card_size(data) {
            selector.selectedIndex = data.index;
            if (data.hasOwnProperty("layout_index")) {
                layoutSelector.selectedIndex = data.layout_index;
            }

            if (data.hasOwnProperty("viewWidth")) {
                widthSlider.value = data.viewWidth;
            }

            if (data.hasOwnProperty("size")) {
                cardTool.template['card-size'] = data.size;
                cardTool.templateChanged();
            }

            if (data.hasOwnProperty("width")) {
                if (typeof data.width === "function") {
                    tryCompareFunction(function() { return cardTool.cardWidth === data.width() }, true);
                } else tryCompare(cardTool, "cardWidth", data.width);
            }

            if (data.hasOwnProperty("height")) {
                if (typeof data.height === "function") {
                    tryCompareFunction(function() { return cardTool.cardHeight === data.height() }, true);
                } else tryCompare(cardTool, "cardHeight", data.height);
            }
        }

        function test_card_title_alignment_data() {
            return [
                { tag: "Art, header, summary", value: Text.AlignLeft, index: 0 },
                { tag: "Header, summary", value: Text.AlignLeft, index: 1 },
                { tag: "Art, header", value: Text.AlignLeft, index: 2 },
                { tag: "Header only", value: Text.AlignLeft, index: 3 },
                { tag: "Header title only", value: Text.AlignHCenter, index: 4 },
                { tag: "Header title and subtitle", value: Text.AlignLeft, index: 5 },
                { tag: "Header title and mascot", value: Text.AlignLeft, index: 6 },
                { tag: "Art, header, summary - small", value: Text.AlignLeft, index: 7 },
                { tag: "Art, header, summary - large", value: Text.AlignLeft, index: 8 },
                { tag: "Art, header, summary - horizontal", value: Text.AlignLeft, index: 9 },
                { tag: "Art, header - portrait", value: Text.AlignLeft, index: 10 },
                { tag: "Title - vertical", value: Text.AlignHCenter, index: 11 },
                { tag: "Title - horizontal", value: Text.AlignLeft, index: 12 },
                { tag: "Title, subtitle - vertical", value: Text.AlignLeft, index: 13 },
                { tag: "Title, attributes - horizontal", value: Text.AlignLeft, index: 14 },
            ];
        }

        function test_card_title_alignment(data) {
            selector.selectedIndex = data.index;

            tryCompareFunction(function() { return findChild(internalCard, "titleLabel").horizontalAlignment == Text.AlignLeft; }, true);

            cardTool.components['title'] = { "field": "title", "align": "center" };
            cardTool.componentsChanged();

            tryCompareFunction(function() { return findChild(internalCard, "titleLabel").horizontalAlignment == data.value; }, true);

            cardTool.components['title'] = { "field": "title" };
            cardTool.componentsChanged();

            tryCompareFunction(function() { return findChild(internalCard, "titleLabel").horizontalAlignment == data.value; }, true);

            cardTool.components['title'] = { "field": "title", "align": "left" };
            cardTool.componentsChanged();

            tryCompareFunction(function() { return findChild(internalCard, "titleLabel").horizontalAlignment == Text.AlignLeft; }, true);
        }

        function test_categoryLayout_data() {
            return [
                { tag: "Default Grid", layout_index: 0, count: 2, viewWidth: units.gu(40), layout: "grid" },
                { tag: "Long carousel", layout_index: 4, count: 6, viewWidth: units.gu(140), layout: "carousel" },
                { tag: "Long carousel fallback", layout_index: 4, count: 5, viewWidth: units.gu(140), layout: "grid" },
                { tag: "Short carousel", layout_index: 4, count: 4, viewWidth: units.gu(30), layout: "carousel" },
                { tag: "Short carousel fallback", layout_index: 4, count: 3, viewWidth: units.gu(30), layout: "grid" },
                { tag: "Journal", layout_index: 2, count: 8, viewWidth: units.gu(30), layout: "journal" }
            ]
        }

        function test_categoryLayout(data) {
            selector.selectedIndex = 0;
            layoutSelector.selectedIndex = data.layout_index;
            cardTool.viewWidth = data.viewWidth;
            cardTool.count = data.count;
            compare(cardTool.categoryLayout, data.layout);
        }
    }
}
