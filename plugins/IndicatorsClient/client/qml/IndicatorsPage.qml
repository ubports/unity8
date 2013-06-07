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

Page {
    id: _page

    title: initialProperties && initialProperties.title ?  initialProperties.title : ""
    property variant initialProperties
    property alias component : page_loader.sourceComponent

    anchors.fill: parent

    Loader {
        id: page_loader
        objectName: "page_loader"

        anchors.fill: parent

        onStatusChanged: {
            if (status == Loader.Ready) {
                for(var pName in initialProperties) {
                    if (item.hasOwnProperty(pName)) {
                        item[pName] = initialProperties[pName]
                    }
                }
                item.start()
            }
        }
    }
}
