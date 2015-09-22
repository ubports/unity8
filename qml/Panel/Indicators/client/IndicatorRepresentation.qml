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
 *      Nick Dedekind <nick.dedekind@canonical.com>
 */

import QtQuick 2.0
import Ubuntu.Components 0.1
import Ubuntu.Components.ListItems 0.1 as ListItem
import "../.."

Page {
    id: root

    title: indicatorProperties && indicatorProperties.title ? indicatorProperties.title :
                                                              indicatorProperties && indicatorProperties.accessibleName ? indicatorProperties.accessibleName
                                                                                                                        : ""
    property variant indicatorProperties

    anchors.fill: parent

    ListItem.Standard {
        id: visualCheckItem
        text: "Enable Visual Representation"
        control: Switch {
            id: visualCheck
            checked: true
        }
    }

    Loader {
        id: pageLoader
        objectName: "pageLoader"
        clip:true
        asynchronous: true

        Rectangle {
            anchors.fill: pageLoader
            color: "#221e1c" // FIXME not in palette yet
        }

        anchors {
            top: visualCheckItem.bottom
            left: parent.left
            right: parent.right
            bottom: buttons.top
            topMargin: units.gu(2)
            bottomMargin: units.gu(2)
        }
        sourceComponent: visualCheck.checked ? page : tree

        Component {
            id: page
            IndicatorPage {
                identifier: model.identifier
                busName: indicatorProperties.busName
                actionsObjectPath: indicatorProperties.actionsObjectPath
                menuObjectPath: indicatorProperties.menuObjectPath
            }
        }
        Component {
            id: tree
            IndicatorsTree {
                identifier: model.identifier
                busName: indicatorProperties.busName
                actionsObjectPath: indicatorProperties.actionsObjectPath
                menuObjectPath: indicatorProperties.menuObjectPath
            }
        }
    }

    Item {
        id: buttons
        anchors {
            left: parent.left
            right: parent.right
            bottom: parent.bottom
            margins: units.gu(1)
        }
        height: childrenRect.height

        Button {
            anchors {
                left: parent.left
            }
            text: "Back"
            onClicked: root.pageStack.reset()
        }
    }
}
