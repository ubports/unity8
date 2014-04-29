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
import Unity.Dash 1.0

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
     \brief Number of cards.
     */
    property int count

    /*!
     \brief Width of the category view.
     */
    property real viewWidth

    /*!
     \brief Scaling factor of selected Carousel item.
     */
    readonly property real carouselSelectedItemScaleFactor: 1.38  // XXX assuming 1.38 carousel scaling factor for cards

    /*!
     \brief Template supplied for the category.
     */
    property var template

    /*!
     \brief Component mapping supplied for the category.
     */
    property var components

    /*!
     \brief The category layout for this card tool.
     */
    property string categoryLayout: {
        var layout = template["category-layout"];

        // carousel fallback mode to grid
        if (layout === "carousel" && count <= Math.ceil(carouselTool.realPathItemCount)) layout = "grid";
        return layout;
    }

    property var cardComponent: CardCreatorCache.getCardComponent(cardTool.template, cardTool.components);

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
        switch (categoryLayout) {
            case "grid":
            case "vertical-journal":
                if (template["card-layout"] === "horizontal") return units.gu(38);
                switch (template["card-size"]) {
                    case "small": return units.gu(12);
                    case "large": return units.gu(38);
                }
                return units.gu(18.5);
            case "carousel":
                return carouselTool.minimumTileWidth;
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
        switch (categoryLayout) {
            case "journal":
                if (template["card-size"] >= 12 && template["card-size"] <= 38) return units.gu(template["card-size"]);
                return units.gu(18.5);
            case "grid":
                return cardLoader.item ? cardLoader.item.implicitHeight : 0
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
    readonly property size artShapeSize: cardLoader.item ? cardLoader.item.artShapeSize : 0

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

    QtObject {
        id: carouselTool

        property real minimumTileWidth: {
            if (cardTool.viewWidth === undefined) return undefined;
            if (cardTool.viewWidth <= units.gu(40)) return units.gu(18);
            if (cardTool.viewWidth >= units.gu(128)) return units.gu(26);
            return units.gu(18 + Math.round((cardTool.viewWidth - units.gu(40)) / units.gu(11)));
        }

        readonly property real pathItemCount: 4.8457 /// (848 / 175) reference values

        property real realPathItemCount: {
            var scaledMinimumTileWidth = minimumTileWidth / cardTool.carouselSelectedItemScaleFactor;
            var tileWidth = Math.max(cardTool.viewWidth / pathItemCount, scaledMinimumTileWidth);
            return Math.min(cardTool.viewWidth / tileWidth, pathItemCount);
        }
    }

    Loader {
        id: cardLoader
        property var fields: ["art", "mascot", "title", "subtitle", "summary"]
        property var maxData: {
            "art": Qt.resolvedUrl("graphics/checkers.png"),
            "mascot": Qt.resolvedUrl("graphics/checkers.png"),
            "title": "—\n—",
            "subtitle": "—",
            "summary": "—\n—\n—\n—\n—"
        }
        sourceComponent: cardTool.cardComponent
        onLoaded: {
//             console.log("CardTool onLoaded");
            item.asynchronous = false;
            item.template = Qt.binding(function() { return cardTool.template; });
            item.components = Qt.binding(function() { return cardTool.components; });
            item.width = Qt.binding(function() { return cardTool.cardWidth || item.implicitWidth; });
            item.height = Qt.binding(function() { return cardTool.cardHeight || item.implicitHeight; });
        }
        Connections {
            target: cardLoader.item
            onComponentsChanged: {
//                 console.log("CardTool onComponentsChanged");
                var data = {};
                for (var k in cardLoader.fields) {
                    var component = cardLoader.item.components[cardLoader.fields[k]];
                    var key = cardLoader.fields[k];
                    if ((typeof component === "string" && component.length > 0) ||
                        (typeof component === "object" && component !== null
                        && typeof component["field"] === "string" && component["field"].length > 0)) {
                        data[key] = cardLoader.maxData[key];
                    }
                }
                cardLoader.item.cardData = data;
            }
        }
    }
}
