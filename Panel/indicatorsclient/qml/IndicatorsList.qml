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

import QtQuick 2.0
import Ubuntu.Components 0.1
import Ubuntu.Components.ListItems 0.1 as ListItem
import IndicatorsClient 0.1 as IndicatorsClient

Page {
    id: page
    anchors.fill: parent
    title: "Plugin list"

    IndicatorsClient.IndicatorsModel {
        id: indicators

        Component.onCompleted: indicators.load()
    }

    ListView {
        id: mainMenu
        objectName: "mainMenu"
        anchors.fill: parent
        model: indicators

        delegate: IndicatorsClient.Menu {
            anchors.left: parent.left
            anchors.right: parent.right
            height: implicitHeight
            progression: isValid
            objectName: identifier

            // Used basic components instead of 'ListItem.Standard' properties because it does not support image resize
            Image {
                id: itemIcon
                anchors.left: parent.left
                anchors.verticalCenter: parent.verticalCenter
                source: iconSource
                smooth: true
                width: units.gu(5)
                height: units.gu(5)
            }

            Label {
                anchors.left: itemIcon.right
                anchors.leftMargin: units.gu(0.5)
                anchors.verticalCenter: parent.verticalCenter
                text: (label != "") ? (title + " (" + label + ")") : title
            }

            onClicked: {
                if (progression) {
                    var props = model.initialProperties

                    var page = Qt.createComponent("IndicatorsPage.qml")
                    pages.push(page.createObject(pages), {"initialProperties" : props, "component" : model.component})
                }
            }
        }
    }
}

