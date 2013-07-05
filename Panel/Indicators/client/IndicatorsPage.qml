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

Page {
    id: _page

    title: indicatorProperties && indicatorProperties.title ?  indicatorProperties.title : ""
    property variant indicatorProperties
    property string pageSource : page_loader.source

    anchors.fill: parent

    ListItem.Standard {
        id: button

        text: "Enable Visual Representation"
        control: Switch {
            id: checked
            checked: true
        }
    }

    Loader {
        id: page_loader
        objectName: "page_loader"

        anchors {
            top: button.bottom
            left: parent.left
            right: parent.right
            bottom: parent.bottom
            topMargin: units.gu(2)
        }
        source : checked.checked ? _page.pageSource : "IndicatorsTree.qml"

        onLoaded: {
            for(var pName in indicatorProperties) {
                if (item.hasOwnProperty(pName)) {
                    item[pName] = indicatorProperties[pName];
                }
            }
            item.start();
        }
    }
}
