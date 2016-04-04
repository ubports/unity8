/*
 * Copyright (C) 2016 Canonical, Ltd.
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
import AccountsService 0.1
import GlobalShortcut 1.0
import Unity.Application 0.1

QtObject {
    id: root

    property GlobalShortcut shortcutNext: GlobalShortcut {
        shortcut: Qt.MetaModifier|Qt.Key_Space
        onTriggered: root.nextKeymap()
        active: root.keymapCount > 1
    }

    property GlobalShortcut shortcutPrevious: GlobalShortcut {
        shortcut: Qt.MetaModifier|Qt.ShiftModifier|Qt.Key_Space
        onTriggered: root.previousKeymap()
        active: root.keymapCount > 1
    }

    readonly property var keymaps: AccountsService.keymaps
    readonly property int keymapCount: keymaps.length
    property int currentKeymapIndex: 0
    readonly property string currentKeymap: keymaps[currentKeymapIndex]

    function nextKeymap() {
        var nextIndex = 0;

        if (currentKeymapIndex !== -1 && currentKeymapIndex < keymapCount - 1) {
            nextIndex = currentKeymapIndex + 1;
        }
        currentKeymapIndex = nextIndex;
    }

    function previousKeymap() {
        var prevIndex = keymapCount - 1;

        if (currentKeymapIndex > 0) {
            prevIndex = currentKeymapIndex - 1;
        }
        currentKeymapIndex = prevIndex;
    }

    property Binding surfaceKeymapBinding: Binding {
        target: MirFocusController.focusedSurface
        property: "keymap"
        value: root.currentKeymap
    }
}
