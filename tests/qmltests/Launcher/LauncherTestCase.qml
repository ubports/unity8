import QtQuick 2.2
import Unity.Test 0.1

UnityTestCase {
    id: root
    when: windowShown

    property Item launcher: null

    function waitUntilLauncherDisappears() {
        var panel = findChild(launcher, "launcherPanel");
        tryCompare(panel, "x", -panel.width, 1000);
    }

    function positionLauncherListAtBeginning() {
        var listView = testCaseTouch.findChild(launcherLoader.item, "launcherListView");
        listView.contentY = -listView.topMargin;
    }
    function positionLauncherListAtEnd() {
        var listView = testCaseTouch.findChild(launcherLoader.item, "launcherListView");
        if ((listView.contentHeight + listView.topMargin + listView.bottomMargin) > listView.height) {
            listView.contentY = listView.topMargin + listView.contentHeight
                - listView.height;
        }
    }
}
