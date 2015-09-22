/*
 * Copyright (C) 2014-2015 Canonical, Ltd.
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
 *
 * Authors: Michael Zanetti <michael.zanetti@canonical.com>
 */

import QtQuick 2.4
import QtQuick.Layouts 1.1
import Ubuntu.Components 1.1
import Unity.Application 0.1
import "../Components/PanelState"
import Utils 0.1
import Ubuntu.Gestures 0.1

Rectangle {
    id: root
    anchors.fill: parent

    // Controls to be set from outside
    property int dragAreaWidth // just to comply with the interface shared between stages
    property real maximizedAppTopMargin
    property bool interactive
    property bool spreadEnabled // just to comply with the interface shared between stages
    property real inverseProgress: 0 // just to comply with the interface shared between stages
    property int shellOrientationAngle: 0
    property int shellOrientation
    property int shellPrimaryOrientation
    property int nativeOrientation
    property bool beingResized: false
    property bool keepDashRunning: true
    property bool suspended: false

    // functions to be called from outside
    function updateFocusedAppOrientation() { /* TODO */ }
    function updateFocusedAppOrientationAnimated() { /* TODO */}

    // To be read from outside
    readonly property var mainApp: ApplicationManager.focusedApplicationId
            ? ApplicationManager.findApplication(ApplicationManager.focusedApplicationId)
            : null
    property int mainAppWindowOrientationAngle: 0
    readonly property bool orientationChangesEnabled: false

    property alias background: wallpaper.source
    property bool altTabPressed: false

    CrossFadeImage {
        id: wallpaper
        anchors.fill: parent
        sourceSize { height: root.height; width: root.width }
        fillMode: Image.PreserveAspectCrop
    }

    Connections {
        target: ApplicationManager
        onApplicationAdded: {
            if (root.state == "altTab") {
                root.state = "";
            }

            ApplicationManager.requestFocusApplication(appId)
        }

        onFocusRequested: {
            var appIndex = priv.indexOf(appId);
            var appDelegate = appRepeater.itemAt(appIndex);
            appDelegate.minimized = false;
            appDelegate.focus = true;
        }
    }

    QtObject {
        id: priv

        readonly property string focusedAppId: ApplicationManager.focusedApplicationId
        readonly property var focusedAppDelegate: {
            var index = indexOf(focusedAppId);
            return index >= 0 && index < appRepeater.count ? appRepeater.itemAt(index) : null
        }

        function indexOf(appId) {
            for (var i = 0; i < ApplicationManager.count; i++) {
                if (ApplicationManager.get(i).appId == appId) {
                    return i;
                }
            }
            return -1;
        }
    }

    Connections {
        target: PanelState
        onClose: {
            ApplicationManager.stopApplication(ApplicationManager.focusedApplicationId)
        }
        onMinimize: appRepeater.itemAt(0).minimize();
        onMaximize: appRepeater.itemAt(0).unmaximize();
    }

    Binding {
        target: PanelState
        property: "buttonsVisible"
        value: priv.focusedAppDelegate !== null && priv.focusedAppDelegate.state === "maximized"
    }

    Rectangle {
        id: spreadBackground
        anchors.fill: parent
        color: "#55000000"
        visible: false
    }

    FocusScope {
        id: appContainer
        objectName: "appContainer"
        anchors.fill: parent
        focus: true

        Keys.onPressed: {
            switch (event.key) {
            case Qt.Key_Left:
            case Qt.Key_Backtab:
                selectPrevious(event.isAutoRepeat)
                event.accepted = true;
                break;
            case Qt.Key_Right:
            case Qt.Key_Tab:
                selectNext(event.isAutoRepeat)
                event.accepted = true;
                break;
            case Qt.Key_Escape:
                appRepeater.highlightedIndex = -1
                event.accepted = true;
            case Qt.Key_Enter:
            case Qt.Key_Return:
            case Qt.Key_Space:
                root.state = ""
                event.accepted = true;
            }
        }

        function selectNext(isAutoRepeat) {
            if (isAutoRepeat && appRepeater.highlightedIndex >= ApplicationManager.count -1) {
                return; // AutoRepeat is not allowed to wrap around
            }

            appRepeater.highlightedIndex = (appRepeater.highlightedIndex + 1) % ApplicationManager.count;
            var newContentX = ((spreadFlickable.contentWidth) / (ApplicationManager.count + 1)) * Math.max(0, Math.min(ApplicationManager.count - 5, appRepeater.highlightedIndex - 3));
            if (spreadFlickable.contentX < newContentX || appRepeater.highlightedIndex == 0) {
                spreadFlickable.snapTo(newContentX)
            }
        }

        function selectPrevious(isAutoRepeat) {
            if (isAutoRepeat && appRepeater.highlightedIndex == 0) {
                return; // AutoRepeat is not allowed to wrap around
            }

            var newIndex = appRepeater.highlightedIndex - 1 >= 0 ? appRepeater.highlightedIndex - 1 : ApplicationManager.count - 1;
            appRepeater.highlightedIndex = newIndex;
            var newContentX = ((spreadFlickable.contentWidth) / (ApplicationManager.count + 1)) * Math.max(0, Math.min(ApplicationManager.count - 5, appRepeater.highlightedIndex - 1));
            if (spreadFlickable.contentX > newContentX || newIndex == ApplicationManager.count -1) {
                spreadFlickable.snapTo(newContentX)
            }
        }

        function focusSelected() {
            if (appRepeater.highlightedIndex != -1) {
                var application = ApplicationManager.get(appRepeater.highlightedIndex);
                ApplicationManager.requestFocusApplication(application.appId)
            }
        }

        Repeater {
            id: appRepeater
            model: ApplicationManager
            objectName: "appRepeater"

            property int highlightedIndex: -1
            property int closingIndex: -1

            function indexOf(delegateItem) {
                for (var i = 0; i < appRepeater.count; i++) {
                    if (appRepeater.itemAt(i) === delegateItem) {
                        return i;
                    }
                }
                return -1;
            }

            delegate: FocusScope {
                id: appDelegate
                z: ApplicationManager.count - index
                y: units.gu(3)
                width: units.gu(60)
                height: units.gu(50)

                property int windowWidth: 0
                property int windowHeight: 0
                // We don't want to resize the actual application when we're transforming things for the spread only
                onWidthChanged: if (appDelegate.state !== "altTab") windowWidth = width
                onHeightChanged: if (appDelegate.state !== "altTab") windowHeight = height

                readonly property int minWidth: units.gu(10)
                readonly property int minHeight: units.gu(10)

                property bool maximized: false
                property bool minimized: false

                onFocusChanged: {
                    if (focus && ApplicationManager.focusedApplicationId !== model.appId) {
                        ApplicationManager.focusApplication(model.appId);
                    }
                }

                Component.onCompleted: {
                    // Focus the top-most or AppMan-focused application on start up.
                    if (ApplicationManager.focusedApplicationId === model.appId && !focus) {
                        focus = true;
                    }
                }

                Binding {
                    target: ApplicationManager.get(index)
                    property: "requestedState"
                    // TODO: figure out some lifecycle policy, like suspending minimized apps
                    //       if running on a tablet or something.
                    // TODO: If the device has a dozen suspended apps because it was running
                    //       in staged mode, when it switches to Windowed mode it will suddenly
                    //       resume all those apps at once. We might want to avoid that.
                    value: ApplicationInfoInterface.RequestedRunning // Always running for now
                }

                function maximize() {
                    minimized = false;
                    maximized = true;
                }
                function minimize() {
                    maximized = false;
                    minimized = true;
                }
                function unmaximize() {
                    minimized = false;
                    maximized = false;
                }

                Behavior on x {
                    id: closeBehavior
                    enabled: appRepeater.closingIndex >= 0
                    UbuntuNumberAnimation {
                        onRunningChanged: if (!running) appRepeater.closingIndex = -1
                    }
                }

                states: [
                    State {
                        name: "normal"; when: !appDelegate.maximized && !appDelegate.minimized && root.state !== "altTab"
                    },
                    State {
                        name: "maximized"; when: appDelegate.maximized && (root.state !== "altTab" || (root.state == "altTab" && !root.workspacesUpdated))
                        PropertyChanges { target: appDelegate; x: 0; y: 0; width: root.width; height: root.height }
                    },
                    State {
                        name: "minimized"; when: appDelegate.minimized && (root.state !== "altTab" || (root.state == "altTab" && !root.workspacesUpdated))
                        PropertyChanges { target: appDelegate; x: -appDelegate.width / 2; scale: units.gu(5) / appDelegate.width; opacity: 0 }
                    },
                    State {
                        name: "altTab"; when: root.state == "altTab" && root.workspacesUpdated
                        PropertyChanges {
                            target: appDelegate
                            x: spreadMaths.animatedX
                            y: spreadMaths.animatedY + (appDelegate.height - decoratedWindow.height) - units.gu(2)
                            width: spreadMaths.spreadHeight
                            height: spreadMaths.sceneHeight
                            angle: spreadMaths.animatedAngle
                            itemScale: spreadMaths.scale
                            itemScaleOriginY: decoratedWindow.height / 2;
                            z: index
                            visible: spreadMaths.itemVisible
                        }
                        PropertyChanges {
                            target: decoratedWindow
                            decorationShown: false
                            highlightShown: index == appRepeater.highlightedIndex
                            state: "transformed"
                            width: spreadMaths.spreadHeight
                            height: spreadMaths.spreadHeight
                            shadowOpacity: spreadMaths.shadowOpacity
                            anchors.topMargin: units.gu(2)
                        }
                        PropertyChanges {
                            target: tileInfo
                            visible: true
                            opacity: spreadMaths.tileInfoOpacity
                        }
                        PropertyChanges {
                            target: spreadSelectArea
                            enabled: true
                        }
                        PropertyChanges {
                            target: windowMoveResizeArea
                            enabled: false
                        }
                    }
                ]
                transitions: [
                    Transition {
                        from: "maximized,minimized,normal,"
                        to: "maximized,minimized,normal,"
                        PropertyAnimation { target: appDelegate; properties: "x,y,opacity,width,height,scale" }
                    },
                    Transition {
                        from: ""
                        to: "altTab"
                        PropertyAction { target: appDelegate; properties: "y,angle,z,itemScale,itemScaleOriginY" }
                        PropertyAction { target: decoratedWindow; properties: "anchors.topMargin" }
                        PropertyAnimation {
                            target: appDelegate; properties: "x"
                            from: root.width
                            duration: rightEdgePushArea.containsMouse ? UbuntuAnimation.FastDuration :0
                            easing: UbuntuAnimation.StandardEasing
                        }
                    }
                ]
                property real angle: 0
                property real itemScale: 1
                property int itemScaleOriginX: 0
                property int itemScaleOriginY: 0

                SpreadMaths {
                    id: spreadMaths
                    flickable: spreadFlickable
                    itemIndex: index
                    totalItems: Math.max(6, ApplicationManager.count)
                    sceneHeight: root.height
                    itemHeight: appDelegate.height
                }

                WindowMoveResizeArea {
                    id: windowMoveResizeArea
                    target: appDelegate
                    minWidth: appDelegate.minWidth
                    minHeight: appDelegate.minHeight
                    resizeHandleWidth: units.gu(2)
                    windowId: model.appId // FIXME: Change this to point to windowId once we have such a thing

                    onPressed: { appDelegate.focus = true; }
                }

                DecoratedWindow {
                    id: decoratedWindow
                    objectName: "decoratedWindow"
                    anchors.left: appDelegate.left
                    anchors.top: appDelegate.top
                    windowWidth: appDelegate.windowWidth
                    windowHeight: appDelegate.windowHeight
                    application: ApplicationManager.get(index)
                    active: ApplicationManager.focusedApplicationId === model.appId
                    focus: true

                    onClose: ApplicationManager.stopApplication(model.appId)
                    onMaximize: appDelegate.maximize()
                    onMinimize: appDelegate.minimize()

                    transform: [
                        Scale {
                            origin.x: itemScaleOriginX
                            origin.y: itemScaleOriginY
                            xScale: itemScale
                            yScale: itemScale
                        },
                        Rotation {
                            origin { x: 0; y: (decoratedWindow.height - (decoratedWindow.height * itemScale / 2)) }
                            axis { x: 0; y: 1; z: 0 }
                            angle: appDelegate.angle
                        }
                    ]

                    MouseArea {
                        id: spreadSelectArea
                        anchors.fill: parent
                        anchors.margins: -units.gu(2)
                        enabled: false
                        onClicked: {
                            appRepeater.highlightedIndex = index;
                            root.state = ""
                        }
                    }
                }

                Image {
                    id: closeImage
                    anchors { left: parent.left; top: parent.top; leftMargin: -height / 2; topMargin: -height / 2 + spreadMaths.closeIconOffset + units.gu(2) }
                    source: "graphics/window-close.svg"
                    readonly property var mousePos: hoverMouseArea.mapToItem(appDelegate, hoverMouseArea.mouseX, hoverMouseArea.mouseY)
                    visible: index == appRepeater.highlightedIndex
                             && mousePos.y < (decoratedWindow.height / 3)
                             && mousePos.y > -units.gu(4)
                             && mousePos.x > -units.gu(4)
                             && mousePos.x < (decoratedWindow.width * 2 / 3)
                    height: units.gu(1.5)
                    width: height
                    sourceSize.width: width
                    sourceSize.height: height

                    MouseArea {
                        id: closeMouseArea
                        objectName: "closeMouseArea"
                        anchors.fill: closeImage
                        anchors.margins: -units.gu(2)
                        onClicked: {
                            appRepeater.closingIndex = index;
                            ApplicationManager.stopApplication(model.appId)
                        }
                    }
                }

                MouseArea {
                    id: tileInfo
                    objectName: "tileInfo"
                    anchors { left: parent.left; top: decoratedWindow.bottom; topMargin: units.gu(5) }
                    width: units.gu(30)
                    height: titleInfoColumn.height
                    visible: false
                    hoverEnabled: true

                    onContainsMouseChanged: {
                        if (containsMouse) {
                            appRepeater.highlightedIndex = index
                        }
                    }

                    onClicked: {
                        root.state = ""
                    }

                    ColumnLayout {
                        id: titleInfoColumn
                        anchors { left: parent.left; top: parent.top; right: parent.right }
                        spacing: units.gu(1)

                        UbuntuShape {
                            Layout.preferredHeight: Math.min(units.gu(6), root.height * .05)
                            Layout.preferredWidth: height * 8 / 7.6
                            image: Image {
                                anchors.fill: parent
                                source: model.icon
                            }
                        }
                        Label {
                            Layout.fillWidth: true
                            Layout.preferredHeight: units.gu(6)
                            text: model.name
                            wrapMode: Text.WordWrap
                            maximumLineCount: 2
                        }
                    }
                }
            }
        }
    }

    MouseArea {
        id: hoverMouseArea
        anchors.fill: appContainer
        propagateComposedEvents: true
        hoverEnabled: true
        enabled: false

        property int scrollAreaWidth: root.width / 3
        property bool progressiveScrollingEnabled: false

        onMouseXChanged: {
            mouse.accepted = false
            if (hoverMouseArea.pressed) return;

            // Find the hovered item and mark it active
            var mapped = mapToItem(appContainer, hoverMouseArea.mouseX, hoverMouseArea.mouseY)
            var itemUnder = appContainer.childAt(mapped.x, mapped.y)
            if (itemUnder) {
                mapped = mapToItem(itemUnder, hoverMouseArea.mouseX, hoverMouseArea.mouseY)
                var delegateChild = itemUnder.childAt(mapped.x, mapped.y)
                if (delegateChild.objectName === "decoratedWindow" || delegateChild.objectName === "tileInfo") {
                    appRepeater.highlightedIndex = appRepeater.indexOf(itemUnder)
                }
            }

            if (spreadFlickable.contentWidth > spreadFlickable.minContentWidth) {
                var margins = spreadFlickable.width * 0.05;

                if (!progressiveScrollingEnabled && mouseX < spreadFlickable.width - scrollAreaWidth) {
                    progressiveScrollingEnabled = true
                }

                // do we need to scroll?
                if (mouseX < scrollAreaWidth) {
                    var progress = Math.min(1, (scrollAreaWidth + margins - mouseX) / (scrollAreaWidth - margins));
                    var contentX = (1 - progress) * (spreadFlickable.contentWidth - spreadFlickable.width)
                    spreadFlickable.contentX = Math.max(0, Math.min(spreadFlickable.contentX, contentX))
                }
                if (mouseX > spreadFlickable.width - scrollAreaWidth && progressiveScrollingEnabled) {
                    var progress = Math.min(1, (mouseX - (spreadFlickable.width - scrollAreaWidth)) / (scrollAreaWidth - margins))
                    var contentX = progress * (spreadFlickable.contentWidth - spreadFlickable.width)
                    spreadFlickable.contentX = Math.min(spreadFlickable.contentWidth - spreadFlickable.width, Math.max(spreadFlickable.contentX, contentX))
                }
            }
        }
        onPressed: mouse.accepted = false
    }

    FloatingFlickable {
        id: spreadFlickable
        objectName: "spreadFlickable"
        anchors.fill: parent
        property int minContentWidth: 6 * Math.min(height / 4, width / 5)
        contentWidth: Math.max(6, ApplicationManager.count) * Math.min(height / 4, width / 5)
        enabled: false

        function snapTo(contentX) {
            snapAnimation.stop();
            snapAnimation.to = contentX
            snapAnimation.start();
        }

        UbuntuNumberAnimation {
            id: snapAnimation
            target: spreadFlickable
            property: "contentX"
        }
    }

    Item {
        id: workspaceSelector
        anchors {
            left: parent.left
            top: parent.top
            right: parent.right
            topMargin: units.gu(3.5) // TODO: should be root.panelHeight
        }
        height: root.height * 0.25
        visible: false

        RowLayout {
            anchors.fill: parent
            spacing: units.gu(1)
            Item { Layout.fillWidth: true }
            Repeater {
                model: 1 // TODO: will be a workspacemodel in the future
                Item {
                    Layout.fillHeight: true
                    Layout.preferredWidth: ((height - units.gu(6)) * root.width / root.height)
                    Image {
                        source: root.background
                        anchors {
                            left: parent.left
                            right: parent.right
                            verticalCenter: parent.verticalCenter
                        }
                        height: parent.height * 0.75

                        // FIXME: This is temporary until we can have multiple Items per surface
                        ShaderEffect {
                            anchors.fill: parent

                            property var source: ShaderEffectSource {
                                id: shaderEffectSource
                                live: false
                                sourceItem: appContainer
                                Connections { target: root; onUpdateWorkspaces: shaderEffectSource.scheduleUpdate() }
                            }

                            fragmentShader: "
                                varying highp vec2 qt_TexCoord0;
                                uniform sampler2D source;
                                void main(void)
                                {
                                    highp vec4 sourceColor = texture2D(source, qt_TexCoord0);
                                    gl_FragColor = sourceColor;
                                }"
                        }
                    }

                    // TODO: This is the bar for the currently selected workspace
                    // Enable this once the workspace stuff is implemented
//                    Rectangle {
//                        anchors { left: parent.left; right: parent.right; bottom: parent.bottom }
//                        height: units.dp(2)
//                        color: UbuntuColors.orange
//                        visible: index == 0 // TODO: should be active workspace index
//                    }
                }

            }
            // TODO: This is the "new workspace" button. Enable this once workspaces are implemented
//            Item {
//                Layout.fillHeight: true
//                Layout.preferredWidth: ((height - units.gu(6)) * root.width / root.height)
//                Rectangle {
//                    anchors {
//                        left: parent.left
//                        right: parent.right
//                        verticalCenter: parent.verticalCenter
//                    }
//                    height: parent.height * 0.75
//                    color: "#22ffffff"

//                    Label {
//                        anchors.centerIn: parent
//                        font.pixelSize: parent.height / 2
//                        text: "+"
//                    }
//                }
//            }
            Item { Layout.fillWidth: true }
        }
    }

    Label {
        id: currentSelectedLabel
        anchors { bottom: parent.bottom; bottomMargin: root.height * 0.625; horizontalCenter: parent.horizontalCenter }
        text: appRepeater.highlightedIndex >= 0 ? ApplicationManager.get(appRepeater.highlightedIndex).name : ""
        visible: false
        fontSize: "large"
    }

    states: [
        State {
            name: "altTab"; when: root.altTabPressed
            PropertyChanges { target: workspaceSelector; visible: true }
            PropertyChanges { target: spreadFlickable; enabled: spreadFlickable.contentWidth > spreadFlickable.minContentWidth }
            PropertyChanges { target: currentSelectedLabel; visible: true }
            PropertyChanges { target: spreadBackground; visible: true }
            PropertyChanges { target: hoverMouseArea; enabled: true }
        }
    ]
    signal updateWorkspaces();
    property bool workspacesUpdated: false
    transitions: [
        Transition {
            from: "*"
            to: "altTab"
            SequentialAnimation {
                PropertyAction { target: hoverMouseArea; property: "progressiveScrollingEnabled"; value: false }
                PropertyAction { target: appRepeater; property: "highlightedIndex"; value: Math.min(ApplicationManager.count - 1, 1) }
                PauseAnimation { duration: 50 }
                PropertyAction { target: workspaceSelector; property: "visible" }
                ScriptAction { script: root.updateWorkspaces() }
                // FIXME: Updating of shaderEffectSource take a bit of time. This is temporary until we can paint multiple items per surface
                PauseAnimation { duration: 10 }
                PropertyAction { target: root; property: "workspacesUpdated"; value: true }
                PropertyAction { target: spreadFlickable; property: "visible" }
                PropertyAction { targets: [currentSelectedLabel,spreadBackground]; property: "visible" }
                PropertyAction { target: spreadFlickable; property: "contentX"; value: 0 }
            }
        },
        Transition {
            from: "*"
            to: "*"
            PropertyAnimation { property: "opacity" }
            PropertyAction { target: root; property: "workspacesUpdated"; value: false }
            ScriptAction { script: { appContainer.focusSelected() } }
            PropertyAction { target: appRepeater; property: "highlightedIndex"; value: -1 }
        }

    ]

    MouseArea {
        id: rightEdgePushArea
        anchors {
            top: parent.top
            right: parent.right
            bottom: parent.bottom
        }
        // TODO: Make this a push to edge thing like the launcher when we can,
        // for now, yes, we want 1 pixel, regardless of the scaling
        width: 1
        hoverEnabled: true
        onContainsMouseChanged: {
            if (containsMouse) {
                root.state = "altTab";
            }
        }
    }
}
