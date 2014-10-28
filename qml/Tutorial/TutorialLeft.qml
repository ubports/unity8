/*
 * Copyright (C) 2014 Canonical, Ltd.
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

TutorialPage {
    id: root

    title: i18n.tr("Left edge")
    text: i18n.tr("Swipe from the <b>left edge</b> to see your <b>favorite apps</b> in the <b>Launcher</b>.")

    bar {
        direction: "right"
    }

    foreground {
        children: [
            Arrow {
                direction: "right"
                anchors {
                    left: parent.left
                    leftMargin: offset + bar.offset
                    top: parent.top
                    topMargin: offset
                }
            }
        ]
    }
}
