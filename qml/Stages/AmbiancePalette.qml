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
 */

import QtQuick 2.0
import Ubuntu.Components 1.1
import Ubuntu.Components.Themes 0.1

// FIXME: copied without modifications from Ubuntu UI Toolkit's Ambiance's theme
Palette {
    normal: PaletteValues {
        background: "#EDEDED"
        backgroundText: "#81888888"
        base: Qt.rgba(0, 0, 0, 0.1)
        baseText: UbuntuColors.lightGrey
        foreground: UbuntuColors.lightGrey
        foregroundText: "#F3F3E7"
        overlay: "#FDFDFD"
        overlayText: UbuntuColors.lightGrey
        field: "#1A000000"
        fieldText: UbuntuColors.darkGrey
    }
    selected: PaletteValues {
        /* FIXME: 'background' does not come from design
           it is used solely in the list items for the selection highlight
           that will go away with the new design.
        */
        background: "#B2E6E6E6"
        backgroundText: UbuntuColors.darkGrey
        selection: Qt.rgba(UbuntuColors.blue.r, UbuntuColors.blue.g, UbuntuColors.blue.b, 0.2)
        foreground: UbuntuColors.orange
        foregroundText: UbuntuColors.darkGrey
        field: "#FFFFFF"
        fieldText: UbuntuColors.darkGrey
    }
}
