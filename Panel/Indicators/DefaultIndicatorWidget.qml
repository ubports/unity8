/*
 * Copyright 2013 Canonical Ltd.
 *
 * This program is free software; you can redistribute it and/or modify
 * it under the terms of the GNU Lesser General Public License as published by
 * the Free Software Foundation; version 3.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU Lesser General Public License for more details.
 *
 * You should have received a copy of the GNU Lesser General Public License
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.
 *
 * Authors:
 *      Nick Dedekind <nick.dedekind@canonical.com>
 */

import QtQuick 2.0
import Ubuntu.Components 0.1
import Unity.Indicators 0.1 as Indicators

Indicators.IndicatorWidget {
    id: indicatorWidget

    width: itemRow.width + units.gu(1)

    property alias label: itemLabel.text
    property alias iconSource: itemImage.source

    Row {
        id: itemRow
        objectName: "itemRow"
        anchors {
            top: parent.top
            bottom: parent.bottom
            horizontalCenter: parent.horizontalCenter
        }
        spacing: units.gu(0.5)

        // FIXME : Should us Ubuntu.Icon . results in low res images
        Image {
            id: itemImage
            objectName: "itemImage"
            visible: source != ""
            height: indicatorWidget.iconSize
            width: indicatorWidget.iconSize
            anchors.verticalCenter: parent.verticalCenter
        }

        Label {
            id: itemLabel
            objectName: "itemLabel"
            color: "#f3f3e7"
            opacity: 0.8
            font.family: "Ubuntu"
            fontSize: "medium"
            anchors.verticalCenter: parent.verticalCenter
            visible: text != ""
        }
    }

    onActionStateChanged: {
        if (action == undefined || !action.valid) {
            return;
        }

        if (action.state == undefined) {
            label = "";
            iconSource = "";
            enabled = false;
            return;
        }

        label = action.state[Indicators.DefaultActionState.Label];
        iconSource = "image://gicon/" + action.state[Indicators.DefaultActionState.IconSource];
        enabled = action.state[Indicators.DefaultActionState.Visible];
    }
}
