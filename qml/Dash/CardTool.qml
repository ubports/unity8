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

Item {
    id: cardTool
    property var template
    property var components

    // FIXME: Saviq
    // Only way for the card below to actually be laid out completely.
    // If invisible or in "data" array, some components are not taken into account.
    width: 0
    height: 0
    clip: true

    property var cardWidth: {
        switch (template !== undefined && template["category-layout"]) {
            case "grid":
            case "vertical-journal":
                if (template["card-layout"] === "horizontal") return units.gu(38);
                switch (template["card-size"]) {
                    case "small": return units.gu(12);
                    case "large": return units.gu(38);
                }
                return units.gu(18.5);
            case undefined:
            case "organic-grid":
            case "journal":
            default:
                return undefined;
        }
    }

    property var cardHeight: {
        switch (template !== undefined && template["category-layout"]) {
            case "journal":
                if (template["card-size"] >= 12 && template["card-size"] <= 38) return units.gu(template["card-size"]);
                return units.gu(18.5);
            case "grid":
                return card.implicitHeight
            case undefined:
            case "organic-grid":
            case "vertical-journal":
            default:
                return undefined;
        }
    }

    property QtObject priv: card

    Card {
        id: card
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
