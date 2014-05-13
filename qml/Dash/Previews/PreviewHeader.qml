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

import QtQuick 2.0
import "../"

/*! This preview widget shows a header that is the same as the card header
 *  The title comes in widgetData["title"]
 *  The mascot comes in widgetData["mascot"]
 *  The subtitle comes in widgetData["subtitle"]
 */

PreviewWidget {
    id: root

    height: childrenRect.height

    CardHeader {
        objectName: "cardHeader"
        mascot: root.widgetData["mascot"] || ""
        title: root.widgetData["title"] || ""
        subtitle: root.widgetData["subtitle"] || ""
        width: parent.width

        titleSize: "large"
        // TODO Change "grey" to Ubuntu.Components.Palette color once updated.
        fontColor: "grey"
    }
}
