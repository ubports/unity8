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
import QMenuModel 0.1
import Unity.Application 0.1

QtObject {
    id: root

    // to be set from outside
    property var focusedSurface: null

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
    // default keymap, either the one remembered by the indicator, or the 1st one selected by user
    property int currentKeymapIndex: actionGroup.currentAction.valid ? actionGroup.currentAction.state : 0
    readonly property string currentKeymap: keymaps[currentKeymapIndex]

    function nextKeymap() {
        var nextIndex = 0;

        if (currentKeymapIndex !== -1 && currentKeymapIndex < keymapCount - 1) {
            nextIndex = currentKeymapIndex + 1;
        }
        currentKeymapIndex = nextIndex;
        if (actionGroup.currentAction.valid) {
            actionGroup.currentAction.updateState(currentKeymapIndex);
        }
    }

    function previousKeymap() {
        var prevIndex = keymapCount - 1;

        if (currentKeymapIndex > 0) {
            prevIndex = currentKeymapIndex - 1;
        }
        currentKeymapIndex = prevIndex;
        if (actionGroup.currentAction.valid) {
            actionGroup.currentAction.updateState(currentKeymapIndex);
        }
    }

    property Binding surfaceKeymapBinding: Binding { // NB: needed mainly for xmir & libertine apps
        target: root.focusedSurface
        property: "keymap"
        value: root.currentKeymap
    }

    property Binding unityKeymapBinding: Binding {
        target: Mir
        property: "currentKeymap"
        value: root.currentKeymap
    }

    // indicator
    property QDBusActionGroup actionGroup: QDBusActionGroup {
        busType: DBus.SessionBus
        busName: "com.canonical.indicator.keyboard"
        objectPath: "/com/canonical/indicator/keyboard"

        property variant currentAction: action("current") // the one that's checked by the indicator
        property variant activeAction: action("active")   // the one that we clicked

        Component.onCompleted: actionGroup.start();
    }

    readonly property int activeActionState: actionGroup.activeAction.valid ? actionGroup.activeAction.state : -1

    onActiveActionStateChanged: {
        if (activeActionState != -1) {
            currentKeymapIndex = activeActionState;
        }
    }
}
