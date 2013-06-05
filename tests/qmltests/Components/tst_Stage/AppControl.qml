/*
 * Copyright 2013 Canonical Ltd.
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

Row {
    id: root
    property string desktopFile
    spacing: units.gu(1)

    property alias checked: checkbox.checked

    Label {text: root.desktopFile
           anchors.verticalCenter: parent.verticalCenter
           width:units.gu(5)}

    CheckBox {
        id: checkbox
        onCheckedChanged: {
            if (checked) {
                var app = fakeAppManager.activateApplication(root.desktopFile)
                stage.activateApplication(root.desktopFile)
            } else {
                fakeAppManager.deacticateApplication(root.desktopFile)
            }
        }
    }
}
