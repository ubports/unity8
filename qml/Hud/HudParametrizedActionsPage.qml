/*
 * Copyright (C) 2012, 2013 Canonical, Ltd.
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
import Ubuntu.Components 1.1
import Ubuntu.Components.Themes.Ambiance 1.1
import "../Components"

Item {
    property alias header: header.title
    signal backPressed
    signal confirmPressed
    signal valuesUpdated
    id: root

    ListModel {
        id: actionItems
    }

    function setItems(items) {
        while (actionItems.count > 0) {
            var item = actionItems.get(0).item
            actionItems.remove(0)
            item.visible = false
            item.destroy()
        }

        var sliderCreator = Qt.createComponent("SliderLabel.qml");
        var first = true
        var topAnchor = header.bottom
        for (var i = 0; i < items.length; i++) {
            var item = items[i]
            if (item["parameter-type"] == "slider")
            {
                var slider = sliderCreator.createObject(flickableColumn);
                slider.anchors.left = flickableColumn.left
                slider.anchors.right = flickableColumn.right
                slider.anchors.topMargin = first ? units.gu(1) : units.gu(2)
                slider.anchors.top = topAnchor
                slider.tooltip = tooltip
                slider.sliderData = item
                topAnchor = slider.bottom
                actionItems.append({"item": slider})
                slider.onValueChanged.connect(valueChanged)
            }
            first = false
        }
    }

    function valueChanged()
    {
        valuesUpdated()
    }

    function values() {
        var values = {}
        for (var i = 0; i < actionItems.count; ++i) {
            var item = actionItems.get(i).item
            values[item.action] = item.value
        }
        return values
    }

    Flickable {
        anchors.top: parent.top
        anchors.bottom: buttons.top
        anchors.left: parent.left
        anchors.right: parent.right
        clip: true

        flickableDirection: Flickable.VerticalFlick
        interactive: !tooltip.visible

        Item {
            id: flickableColumn
            anchors.top: parent.top
            anchors.left: parent.left
            anchors.right: parent.right

            PageHeadStyle {
                id: header
                anchors.top: parent.top
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.topMargin: units.gu(1)
                height: units.gu(6.5)
                contentHeight: height
                separatorSource: ""
                property var styledItem: header
                property string title
                property var config: PageHeadConfiguration { }
            }
        }
    }
    Item {
        id: buttons
        anchors.bottom: parent.bottom
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.margins: units.gu(1)
        height: confirmButton.height

        Button {
            id: backButton
            anchors.left: parent.left
            anchors.top: parent.top
            anchors.bottom: parent.bottom
            width: units.gu(7)
            color: "black"
            opacity: 0.25
            MouseArea {
                anchors.fill: parent
                onClicked: backPressed()
            }
        }
        Image {
            anchors.centerIn: backButton
            source: "graphics/icon_arrow.png"
        }

        Button {
            id: confirmButton
            anchors.right: parent.right
            width: units.gu(13)
            height: units.gu(5)
            text: i18n.tr("Confirm")
            color: "#F05D22"
            onClicked: confirmPressed()
        }
    }

    Item {
        id: tooltip
        property variant target: undefined
        visible: target != undefined
        y: visible ? root.mapFromItem(target.parent, 0, target.y).y - height : 0
        x: visible ? target.anchors.leftMargin + target.__internals.thumb.x + target.__internals.thumb.width / 2 - width / 2 : 0

        width: childrenRect.width
        height: childrenRect.height

        Rectangle {
            id: tooltipRectangle
            width: units.gu(8)
            height: units.gu(6)
            color: "white"
            radius: units.gu(0.5)

            Label {
                anchors.fill: parent
                text: tooltip.target ? tooltip.target.realFormatValue(tooltip.target.value) : ""
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
                fontSize: "large"
            }
        }
        Image {
            id: tooltipTip
            source: "graphics/popup_triangle.png"

            anchors.top: tooltipRectangle.bottom
            anchors.horizontalCenter: parent.horizontalCenter
        }

    }
}
