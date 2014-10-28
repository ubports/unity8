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

    title: i18n.tr("Top edge")
    text: i18n.tr("<b>Swipe down</b> from the <b>top edge</b> to see <b>settings and notifications</b>.")

    bar {
        direction: "down"
    }

    foreground {
        children: [
            Arrow {
                direction: "down"
                anchors {
                    top: parent.top
                    topMargin: offset + bar.offset
                    horizontalCenter: parent.horizontalCenter
                }
            }
        ]
    }
}
