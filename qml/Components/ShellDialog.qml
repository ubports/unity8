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

import Ubuntu.Components 1.1
import Ubuntu.Components.Popups 0.1

/*
    A Dialog configured for use as a proper in-scene Dialog

    This is a helper component for Dialogs.qml, thus some assumptions
    on context are (or will be) made here.
 */
Dialog {
    automaticOrientation: false

    // NB: PopupBase, Dialog's superclass, will check for the existence of this property
    property bool reparentToRootItem: false

    onVisibleChanged: { if (!visible) { dialogLoader.active = false; } }

    Keys.onEscapePressed: hide()

    focus: true

    Component.onCompleted: {
        show();
    }
}
