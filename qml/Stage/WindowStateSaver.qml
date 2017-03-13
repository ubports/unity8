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
import Ubuntu.Components 1.3
import Utils 0.1

QtObject {
    id: root

    // set from outside
    property var target
    property int screenWidth: 0
    property int screenHeight: 0
    property int leftMargin: 0
    property int minimumY: 0

    property int loadedState

    function load() {
        var defaultWidth = units.gu(60);
        var defaultHeight = units.gu(50);
        var windowGeometry = WindowStateStorage.getGeometry(target.appId,
                                                            Qt.rect(target.windowedX, target.windowedY, defaultWidth, defaultHeight));

        target.windowedWidth = Qt.binding(function() { return Math.min(Math.max(windowGeometry.width, target.minimumWidth), screenWidth - root.leftMargin); });
        target.windowedHeight = Qt.binding(function() { return Math.min(Math.max(windowGeometry.height, target.minimumHeight),
                                                                        screenHeight - (target.fullscreen ? 0 : minimumY)); });
        target.windowedX = Qt.binding(function() { return Math.max(Math.min(windowGeometry.x, screenWidth - root.leftMargin - target.windowedWidth),
                                                           (target.fullscreen ? 0 : root.leftMargin)); });
        target.windowedY = Qt.binding(function() { return Math.max(Math.min(windowGeometry.y, screenHeight - target.windowedHeight), minimumY); });

        target.updateNormalGeometry();

        // initialize the x/y to restore to
        target.restoredX = target.normalX;
        target.restoredY = target.normalY;

        loadedState = WindowStateStorage.getState(target.appId, WindowStateStorage.WindowStateNormal);
    }

    function save() {
        var state = target.windowState;
        if (state === WindowStateStorage.WindowStateRestored) {
            state = WindowStateStorage.WindowStateNormal;
        }

        WindowStateStorage.saveState(target.appId, state & ~WindowStateStorage.WindowStateMinimized); // clear the minimized bit when saving
        WindowStateStorage.saveGeometry(target.appId, Qt.rect(target.normalX, target.normalY, target.normalWidth, target.normalHeight));
    }
}
