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

import QtQuick 2.4
import Ubuntu.Components 1.3
import "../../../../qml/Components"

Row {
    property LazyImage image

    anchors { left: parent.left; right: parent.right }
    spacing: units.gu(1)

    function blank() { blankButton.clicked() }
    function wide() { wideButton.clicked() }
    function square() { squareButton.clicked() }
    function portrait() { portraitButton.clicked() }
    function badpath() { badpathButton.clicked() }

    Button {
        id: blankButton
        width: parent / 5
        text: "Blank"
        onClicked: image.source = ""
    }

    Button {
        id: wideButton
        width: parent / 5
        text: "Wide"
        onClicked: image.source = "wide.png"
    }

    Button {
        id: squareButton
        width: parent / 5
        text: "Square"
        onClicked: image.source = "square.png"
    }

    Button {
        id: portraitButton
        width: parent / 5
        text: "Portrait"
        onClicked: image.source = "portrait.png"
    }

    Button {
        id: badpathButton
        width: parent / 5
        text: "Bad path"
        onClicked: image.source = "bad/path"
    }
}
