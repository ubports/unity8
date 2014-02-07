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

import QtQuick 2.0
import Ubuntu.Components 0.1

Item {
    id: root
    property alias mascot: mascotImage.source
    property alias title: titleLabel.text
    property alias subtitle: subtitleLabel.text
    property alias price: priceLabel.text
    property alias oldPrice: oldPriceLabel.text
    property alias altPrice: altPriceLabel.text

    visible: mascotImage.status === Image.Ready || title || price
    height: row.height > 0 ? row.height + row.margins * 2 : 0

    Row {
        id: row
        objectName: "outerRow"

        property real margins: units.gu(1)

        anchors {
            top: parent.top; left: parent.left; right: parent.right
            margins: margins
            leftMargin: spacing
            rightMargin: spacing
        }
        spacing: mascotShape.visible ? margins : 0

        UbuntuShape {
            id: mascotShape
            objectName: "mascotShape"

            width: units.gu(8)
            height: units.gu(8)
            visible: image.status === Image.Ready

            image: Image {
                id: mascotImage
                sourceSize { width: mascotShape.width; height: mascotShape.height }
            }
        }

        Column {
            objectName: "column"
            width: parent.width - x
            spacing: units.gu(0.5)

            Label {
                id: titleLabel
                objectName: "titleLabel"
                anchors { left: parent.left; right: parent.right }
                elide: Text.ElideRight
                font.weight: Font.DemiBold
                wrapMode: Text.Wrap
                maximumLineCount: 2
                fontSize: "small"
                // TODO karni (for each Label): Update Ubuntu.Components.Themes.Palette and use theme color instead
                color: template["overlay"] === true ? "white" : "grey" // Theme.palette.normal.backgroundText
            }

            Label {
                id: subtitleLabel
                objectName: "subtitleLabel"
                anchors { left: parent.left; right: parent.right }
                elide: Text.ElideRight
                font.weight: Font.Light
                visible: titleLabel.text && text
                fontSize: "x-small"
                color: template["overlay"] === true ? "white" : "grey" // Theme.palette.normal.backgroundText
            }

            Row {
                id: prices
                objectName: "prices"
                anchors { left: parent.left; right: parent.right }

                property int labels: {
                    var labels = 1; // price always visible
                    if (oldPriceLabel.text !== "") labels += 1;
                    if (altPriceLabel.text !== "") labels += 1;
                    return labels;
                }
                property real labelWidth: width / labels

                Label {
                    id: priceLabel
                    width: parent.labelWidth
                    elide: Text.ElideRight
                    font.weight: Font.DemiBold
                    color: "grey" // Theme.palette.normal.backgroundText
                    visible: text
                }

                Label {
                    id: oldPriceLabel
                    objectName: "oldPriceLabel"
                    width: parent.labelWidth
                    elide: Text.ElideRight
                    horizontalAlignment: parent.labels === 3 ? Text.AlignHCenter : Text.AlignRight
                    visible: text
                }

                Label {
                    id: altPriceLabel
                    width: parent.labelWidth
                    elide: Text.ElideRight
                    horizontalAlignment: Text.AlignRight
                    visible: text
                }
            }
        }
    }
}
