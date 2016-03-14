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

import QtQuick 2.4

import Ubuntu.Components 1.3
import Ubuntu.Components.Popups 1.3

/*
    A Dialog configured for use as a proper in-scene Dialog

    This is a helper component for Dialogs.qml, thus some assumptions
    on context are (or will be) made here.
 */
Dialog {
    automaticOrientation: false

    // NB: PopupBase, Dialog's superclass, will check for the existence of this property
    property bool reparentToRootItem: false

    onVisibleChanged: { if (!visible && dialogLoader) { dialogLoader.active = false; } }

    Keys.onEscapePressed: hide()

    focus: true

    // FIXME: this is a hack because Dialog subtheming seems broken atm
    // https://bugs.launchpad.net/ubuntu/+source/ubuntu-ui-toolkit/+bug/1555548
    ThemeSettings {
        id: themeHack
        name: "Ubuntu.Components.Themes.Ambiance"
    }

    Component.onCompleted: {
        __foreground.theme = themeHack
        show();
    }
}
