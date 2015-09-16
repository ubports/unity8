/*
 * Copyright (C) 2014,2015 Canonical, Ltd.
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

import QtQuick 2.3
import Ubuntu.Components 1.1
import "." as LocalComponents

TutorialPage {
    id: root

    property var launcher

    Connections {
        target: root.launcher

        onStateChanged: {
            if (root.launcher.state === "visible") {
                root.hide();
            }
        }
    }

    arrow {
        anchors.left: root.left
        anchors.verticalCenter: root.verticalCenter
    }

    label {
        text: i18n.tr("Short swipe from the left edge to open the launcher")
        anchors.left: arrow.right
        anchors.right: root.right
        anchors.verticalCenter: arrow.verticalCenter
    }
}
