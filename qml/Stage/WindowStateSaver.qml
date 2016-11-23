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

        var windowState = WindowStateStorage.getState(target.appId, WindowStateStorage.WindowStateNormal)
        target.restore(false /* animated */, windowState);

        // initialize the x/y to restore to
        target.restoredX = windowGeometry.x;
        target.restoredY = windowGeometry.y;
    }

    function save() {
        var state = target.windowState;
        if (state === WindowStateStorage.WindowStateRestored) {
            state = WindowStateStorage.WindowStateNormal;
        }

        WindowStateStorage.saveState(target.appId, state & ~WindowStateStorage.WindowStateMinimized); // clear the minimized bit when saving
        WindowStateStorage.saveGeometry(target.appId, Qt.rect(target.windowedX, target.windowedY,
                                                                   target.windowedWidth, target.windowedHeight));
    }
}
