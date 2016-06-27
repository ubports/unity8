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
 *      Renato Araujo Oliveira Filho <renato@canonical.com>
 */

import QtQuick 2.4
import Ubuntu.Components 1.3
import Ubuntu.Components.ListItems 1.3 as ListItem
import Unity.Indicators 0.1 as Indicators
import "../.."

Page {
    id: page
    anchors.fill: parent
    property string profile: ""
    title: "Plugin list"

    Indicators.IndicatorsModel {
        id: indicatorsModel
        profile: page.profile
        Component.onCompleted: load()
    }

    ListView {
        id: mainMenu
        objectName: "mainMenu"
        anchors.fill: parent
        model: indicatorsModel

        delegate: Rectangle {
            color: "#221e1c"

            anchors.left: parent.left
            anchors.right: parent.right
            height: menuItem.height

            ListItem.Standard {
                id: menuItem
                anchors.left: parent.left
                anchors.right: parent.right
                objectName: identifier

                text: identifier

                onClicked: {
                    var new_page = Qt.createComponent("IndicatorRepresentation.qml");
                    if (new_page.status !== Component.Ready) {
                        if (new_page.status === Component.Error)
                            console.error("Error: " + new_page.errorString());

                        return;
                    }

                    page.pageStack.push(new_page.createObject(pages), {"indicatorProperties" : model.indicatorProperties });
                }
            }
        }
    }
}
