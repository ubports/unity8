/*
 * Copyright (C) 2017 Canonical, Ltd.
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

import QtQuick 2.4
import Ubuntu.Components 1.3

AbstractButton {
    id: root

    property bool highlighted: false

    UbuntuShape {
        width: parent.width - units.gu(2)
        anchors.horizontalCenter: parent.horizontalCenter
        height: parent.height - units.gu(1)
        color: "#20ffffff"
        aspect: UbuntuShape.Flat

        StyledItem {
            styleName: "FocusShape"
            anchors.fill: parent
            activeFocusOnTab: true
            StyleHints {
                visible: root.highlighted
            }
        }

        Row {
            anchors.fill: parent
            anchors.margins: units.gu(1)
            spacing: units.gu(1)

            Icon {
                height: units.gu(2.2)
                width: height
                name: "stock_application"
                anchors.verticalCenter: parent.verticalCenter
                color: "white"
            }

            Label {
                text: i18n.tr("More apps in the store")
                anchors.verticalCenter: parent.verticalCenter
                fontSize: "small"
            }

            Icon {
                height: units.gu(2.5)
                width: height
                anchors.verticalCenter: parent.verticalCenter
                name: "go-next"
                color: "white"
            }
        }
    }
}
