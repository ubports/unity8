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

/*!
 \brief Tool for introspecting Card properties.

 Some properties of Cards we need to determine category-wide (like card sizes in grid),
 so we should not do them per-Card but in the category renderer.

 This component creates an invisible card filled with maximum mapped data and calculates
 or measures card properties for this configuration.
 */

Item {
    id: cardTool
    /*!
     \brief Template supplied for the category.
     */
    property var template

    /*!
     \brief Component mapping supplied for the category.
     */
    property var components

    /*!
     \brief Width of the view, based on which carousel width is calculated.
     */
    property var viewWidth

    // FIXME: Saviq
    // Only way for the card below to actually be laid out completely.
    // If invisible or in "data" array, some components are not taken into account.
    width: 0
    height: 0
    clip: true

    /*!
     type:real \brief Width to be enforced on the card in this configuration.

     If undefined, should use implicit width of the actual card.
     */
    readonly property var cardWidth: {
        switch (template !== undefined && template["category-layout"]) {
            case "grid":
            case "vertical-journal":
                if (template["card-layout"] === "horizontal") return units.gu(38);
                switch (template["card-size"]) {
                    case "small": return units.gu(12);
                    case "large": return units.gu(38);
                }
                return units.gu(18.5);
            case "carousel":
                if (viewWidth === undefined) return undefined
                if (viewWidth <= units.gu(40)) return units.gu(18)
                if (viewWidth >= units.gu(128)) return units.gu(26)
                return units.gu(18 + Math.round((viewWidth - units.gu(40))/ units.gu(11)))
            case undefined:
            case "organic-grid":
            case "journal":
            default:
                return undefined;
        }
    }

    /*!
     type:real \brief Height to be enforced on the card in this configuration.

     If undefined, should use implicit height of the actual card.
     */
    readonly property var cardHeight: {
        switch (template !== undefined && template["category-layout"]) {
            case "journal":
                if (template["card-size"] >= 12 && template["card-size"] <= 38) return units.gu(template["card-size"]);
                return units.gu(18.5);
            case "grid":
                return card.implicitHeight
            case "carousel":
                return cardWidth / (components ? components["art"]["aspect-ratio"] : 1)
            case undefined:
            case "organic-grid":
            case "vertical-journal":
            default:
                return undefined;
        }
    }

    /*!
     type:real \brief Height of the card's header.
    */
    readonly property alias headerHeight: card.headerHeight

    /*!
     \brief Desired alignment of header components.
     */
    readonly property int headerAlignment: {
        var subtitle = components["subtitle"];
        var price = components["price"];
        var summary = components["summary"];

        var hasSubtitle = subtitle && (typeof subtitle === "string" || subtitle["field"])
        var hasPrice = price && (typeof price === "string" || subtitle["field"]);
        var hasSummary = summary && (typeof summary === "string" || summary["field"])

        var isOnlyTextComponent = !hasSubtitle && !hasPrice && !hasSummary;
        if (!isOnlyTextComponent) return Text.AlignLeft;

        return (template["card-layout"] === "horizontal") ? Text.AlignLeft : Text.AlignHCenter;
    }

    Card {
        id: card
        objectName: "card"
        template: cardTool.template
        components: cardTool.components

        width: cardTool.cardWidth || implicitWidth
        height: cardTool.cardHeight || implicitHeight

        property var fields: ["art", "mascot", "title", "subtitle", "summary"]
        property var maxData: {
            "art": Qt.resolvedUrl("graphics/checkers.png"),
            "mascot": Qt.resolvedUrl("graphics/checkers.png"),
            "title": "—\n—",
            "subtitle": "—",
            "summary": "—\n—\n—\n—\n—"
        }

        onComponentsChanged: {
            var data = {};
            for (var k in fields) {
                var component = components[fields[k]];
                var key = fields[k];
                if ((typeof component === "string" && component.length > 0) ||
                    (typeof component === "object" && component !== null
                     && typeof component["field"] === "string" && component["field"].length > 0)) {
                    data[key] = maxData[key];
                }
            }
            cardData = data;
        }
    }
}
