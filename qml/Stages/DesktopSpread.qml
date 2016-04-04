/*
 * Copyright (C) 2015-2016 Canonical, Ltd.
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
import QtQuick.Layouts 1.1
import Ubuntu.Components 1.3
import Ubuntu.Gestures 0.1
import Unity.Application 0.1
import "../Components"
import Utils 0.1

FocusScope {
    id: root

    property bool altTabPressed: false
    property Item workspace: null

    readonly property alias ready: blurLayer.ready
    readonly property alias highlightedIndex: spreadRepeater.highlightedIndex

    signal playFocusAnimation(int index)

    function show() {
        spreadContainer.animateIn = true;
        root.state = "altTab";
    }

    onFocusChanged: {
        // When the spread comes active, we want to keep focus to the input handler below
        // Make sure nothing inside the ApplicationWindow grabs our focus!
        if (focus) {
            forceActiveFocus();
        }
    }

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
            spreadRepeater.highlightedIndex = -1
            // Falling through intentionally
        case Qt.Key_Enter:
        case Qt.Key_Return:
        case Qt.Key_Space:
            root.state = ""
            event.accepted = true;
        }
    }

    function selectNext(isAutoRepeat) {
        if (isAutoRepeat && spreadRepeater.highlightedIndex >= topLevelSurfaceList.count -1) {
            return; // AutoRepeat is not allowed to wrap around
        }

        spreadRepeater.highlightedIndex = (spreadRepeater.highlightedIndex + 1) % topLevelSurfaceList.count;
        var newContentX = ((spreadFlickable.contentWidth) / (topLevelSurfaceList.count + 1)) * Math.max(0, Math.min(topLevelSurfaceList.count - 5, spreadRepeater.highlightedIndex - 3));
        if (spreadFlickable.contentX < newContentX || spreadRepeater.highlightedIndex == 0) {
            spreadFlickable.snapTo(newContentX)
        }
    }

    function selectPrevious(isAutoRepeat) {
        if (isAutoRepeat && spreadRepeater.highlightedIndex == 0) {
            return; // AutoRepeat is not allowed to wrap around
        }

        var newIndex = spreadRepeater.highlightedIndex - 1 >= 0 ? spreadRepeater.highlightedIndex - 1 : topLevelSurfaceList.count - 1;
        spreadRepeater.highlightedIndex = newIndex;
        var newContentX = ((spreadFlickable.contentWidth) / (topLevelSurfaceList.count + 1)) * Math.max(0, Math.min(topLevelSurfaceList.count - 5, spreadRepeater.highlightedIndex - 1));
        if (spreadFlickable.contentX > newContentX || newIndex == topLevelSurfaceList.count -1) {
            spreadFlickable.snapTo(newContentX)
        }
    }

    function focusSelected() {
        if (spreadRepeater.highlightedIndex != -1) {
            if (spreadContainer.visible) {
                root.playFocusAnimation(spreadRepeater.highlightedIndex)
            }
            var surface = topLevelSurfaceList.surfaceAt(spreadRepeater.highlightedIndex);
            surface.requestFocus();
        }
    }

    function cancel() {
        spreadRepeater.highlightedIndex = -1;
        state = ""
    }

    BlurLayer {
        id: blurLayer
        anchors.fill: parent
        source: root.workspace
        visible: false
    }

    Rectangle {
        id: spreadBackground
        anchors.fill: parent
        color: "#B2000000"
        visible: false
        opacity: visible ? 1 : 0
        Behavior on opacity {
            UbuntuNumberAnimation { duration: UbuntuAnimation.SnapDuration }
        }
    }

    MouseArea {
        id: eventEater
        anchors.fill: parent
        visible: spreadBackground.visible
        enabled: visible
    }

    Item {
        id: spreadContainer
        objectName: "spreadContainer"
        anchors.fill: parent
        visible: false

        property bool animateIn: false

        Repeater {
            id: spreadRepeater
            objectName: "spreadRepeater"
            model: topLevelSurfaceList

            property int highlightedIndex: -1
            property int closingIndex: -1

            function indexOf(delegateItem) {
                for (var i = 0; i < spreadRepeater.count; i++) {
                    if (spreadRepeater.itemAt(i) === delegateItem) {
                        return i;
                    }
                }
                return -1;
            }

            delegate: Item {
                id: spreadDelegate
                objectName: "spreadDelegate"
                width: units.gu(20)
                height: units.gu(20)

                property real angle: 0
                property real itemScale: 1
                property int itemScaleOriginX: 0
                property int itemScaleOriginY: 0

                Behavior on x {
                    id: closeBehavior
                    enabled: spreadRepeater.closingIndex >= 0
                    UbuntuNumberAnimation {
                        onRunningChanged: if (!running) spreadRepeater.closingIndex = -1
                    }
                }

                DesktopSpreadDelegate {
                    id: clippedSpreadDelegate
                    objectName: "clippedSpreadDelegate"
                    anchors.left: parent.left
                    anchors.top: parent.top
                    application: model.application
                    surface: model.surface
                    width: spreadMaths.spreadHeight
                    height: spreadMaths.spreadHeight

                    transform: [
                        Scale {
                            origin.x: itemScaleOriginX
                            origin.y: itemScaleOriginY
                            xScale: itemScale
                            yScale: itemScale
                        },
                        Rotation {
                            origin { x: 0; y: (clippedSpreadDelegate.height - (clippedSpreadDelegate.height * itemScale / 2)) }
                            axis { x: 0; y: 1; z: 0 }
                            angle: spreadDelegate.angle
                        }
                    ]

                    MouseArea {
                        id: spreadSelectArea
                        anchors.fill: parent
                        anchors.margins: -units.gu(2)
                        enabled: false
                        onClicked: {
                            spreadRepeater.highlightedIndex = index;
                            root.state = "";
                        }
                    }
                }

                SpreadMaths {
                    id: spreadMaths
                    flickable: spreadFlickable
                    itemIndex: index
                    totalItems: Math.max(6, topLevelSurfaceList.count)
                    sceneHeight: root.height
                    itemHeight: spreadDelegate.height
                }

                states: [
                    State {
                        name: "altTab"; when: root.state == "altTab" && spreadContainer.visible
                        PropertyChanges {
                            target: spreadDelegate
                            x: spreadMaths.animatedX
                            y: spreadMaths.animatedY + (spreadDelegate.height - clippedSpreadDelegate.height) - units.gu(2)
                            width: spreadMaths.spreadHeight
                            height: spreadMaths.sceneHeight
                            angle: spreadMaths.animatedAngle
                            itemScale: spreadMaths.scale
                            itemScaleOriginY: clippedSpreadDelegate.height / 2;
                            z: index
                            visible: spreadMaths.itemVisible
                        }
                        PropertyChanges {
                            target: clippedSpreadDelegate
                            highlightShown: index == spreadRepeater.highlightedIndex
                            state: "transformed"
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
                    }
                ]
                transitions: [
                    Transition {
                        from: ""
                        to: "altTab"
                        SequentialAnimation {
                            ParallelAnimation {
                                PropertyAction { target: spreadDelegate; properties: "y,height,width,angle,z,itemScale,itemScaleOriginY,visible" }
                                PropertyAction { target: clippedSpreadDelegate; properties: "anchors.topMargin" }
                                PropertyAnimation {
                                    target: spreadDelegate; properties: "x"
                                    from: root.width
                                    duration: spreadContainer.animateIn ? UbuntuAnimation.FastDuration :0
                                    easing: UbuntuAnimation.StandardEasing
                                }
                                UbuntuNumberAnimation { target: clippedSpreadDelegate; property: "shadowOpacity"; from: 0; to: spreadMaths.shadowOpacity; duration: spreadContainer.animateIn ? UbuntuAnimation.FastDuration : 0 }
                                UbuntuNumberAnimation { target: tileInfo; property: "opacity"; from: 0; to: spreadMaths.tileInfoOpacity; duration: spreadContainer.animateIn ? UbuntuAnimation.FastDuration : 0 }
                            }
                            PropertyAction { target: spreadSelectArea; property: "enabled" }
                        }
                    }
                ]

                MouseArea {
                    id: tileInfo
                    objectName: "tileInfo"
                    anchors {
                        left: parent.left
                        top: clippedSpreadDelegate.bottom
                        topMargin: ((spreadMaths.sceneHeight - spreadDelegate.y) - clippedSpreadDelegate.height) * 0.2
                    }
                    property int nextItemX: spreadRepeater.count > index + 1 ? spreadRepeater.itemAt(index + 1).x : spreadDelegate.x + units.gu(30)
                    width: Math.min(units.gu(30), nextItemX - spreadDelegate.x)
                    height: titleInfoColumn.height
                    visible: false
                    hoverEnabled: true

                    onContainsMouseChanged: {
                        if (containsMouse) {
                            spreadRepeater.highlightedIndex = index
                        }
                    }

                    onClicked: {
                        root.state = ""
                    }

                    ColumnLayout {
                        id: titleInfoColumn
                        anchors { left: parent.left; top: parent.top; right: parent.right }
                        spacing: units.gu(1)

                        UbuntuShapeForItem {
                            Layout.preferredHeight: Math.min(units.gu(6), root.height * .05)
                            Layout.preferredWidth: height * 8 / 7.6
                            image: Image {
                                anchors.fill: parent
                                source: model.application.icon
                                Rectangle {
                                    anchors.fill: parent
                                    color: "black"
                                    opacity: clippedSpreadDelegate.highlightShown ? 0 : .1
                                    Behavior on opacity {
                                        UbuntuNumberAnimation { duration: UbuntuAnimation.SnapDuration }
                                    }
                                }
                            }
                        }
                        Label {
                            Layout.fillWidth: true
                            Layout.preferredHeight: units.gu(6)
                            text: model.surface ? model.surface.name : ""
                            wrapMode: Text.WordWrap
                            elide: Text.ElideRight
                            maximumLineCount: 2
                        }
                    }
                }

                Image {
                    id: closeImage
                    anchors { left: parent.left; top: parent.top; leftMargin: -height / 2; topMargin: -height / 2 + spreadMaths.closeIconOffset + units.gu(2) }
                    source: "graphics/window-close.svg"
                    readonly property var mousePos: hoverMouseArea.mapToItem(spreadDelegate, hoverMouseArea.mouseX, hoverMouseArea.mouseY)
                    visible: index == spreadRepeater.highlightedIndex
                             && mousePos.y < (clippedSpreadDelegate.height / 3)
                             && mousePos.y > -units.gu(4)
                             && mousePos.x > -units.gu(4)
                             && mousePos.x < (clippedSpreadDelegate.width * 2 / 3)
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
                            spreadRepeater.closingIndex = index;
                            model.surface.close();
                        }
                    }
                }
            }
        }
    }


    MouseArea {
        id: hoverMouseArea
        objectName: "hoverMouseArea"
        anchors.fill: spreadContainer
        propagateComposedEvents: true
        hoverEnabled: true
        enabled: false
        visible: enabled

        property int scrollAreaWidth: root.width / 3
        property bool progressiveScrollingEnabled: false

        onMouseXChanged: {
            mouse.accepted = false

            if (hoverMouseArea.pressed) {
                return;
            }

            // Find the hovered item and mark it active
            var mapped = mapToItem(spreadContainer, hoverMouseArea.mouseX, hoverMouseArea.mouseY)
            var itemUnder = spreadContainer.childAt(mapped.x, mapped.y)
            if (itemUnder) {
                mapped = mapToItem(itemUnder, hoverMouseArea.mouseX, hoverMouseArea.mouseY)
                var delegateChild = itemUnder.childAt(mapped.x, mapped.y)
                if (delegateChild && (delegateChild.objectName === "clippedSpreadDelegate" || delegateChild.objectName === "tileInfo")) {
                    spreadRepeater.highlightedIndex = spreadRepeater.indexOf(itemUnder)
                }
            }

            if (spreadFlickable.contentWidth > spreadFlickable.minContentWidth) {
                var margins = spreadFlickable.width * 0.05;

                if (!progressiveScrollingEnabled && mouseX < spreadFlickable.width - scrollAreaWidth) {
                    progressiveScrollingEnabled = true
                }

                // do we need to scroll?
                if (mouseX < scrollAreaWidth + margins) {
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
        contentWidth: Math.max(6, topLevelSurfaceList.count) * Math.min(height / 4, width / 5)
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
            topMargin: units.gu(3.5)
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

                        ShaderEffect {
                            anchors.fill: parent

                            property var source: ShaderEffectSource {
                                id: shaderEffectSource
                                sourceItem: root.workspace
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
        text: spreadRepeater.highlightedIndex >= 0 ? topLevelSurfaceList.surfaceAt(spreadRepeater.highlightedIndex).name : ""
        visible: false
        fontSize: "large"
    }

    states: [
        State {
            name: "altTab"; when: root.altTabPressed
            PropertyChanges { target: blurLayer; saturation: 0.8; blurRadius: 60; visible: true }
            PropertyChanges { target: workspaceSelector; visible: true }
            PropertyChanges { target: spreadContainer; visible: true }
            PropertyChanges { target: spreadFlickable; enabled: spreadFlickable.contentWidth > spreadFlickable.minContentWidth }
            PropertyChanges { target: currentSelectedLabel; visible: true }
            PropertyChanges { target: spreadBackground; visible: true }
            PropertyChanges { target: hoverMouseArea; enabled: true }
        }
    ]
    transitions: [
        Transition {
            from: "*"
            to: "altTab"
            SequentialAnimation {
                PropertyAction { target: spreadRepeater; property: "highlightedIndex"; value: Math.min(topLevelSurfaceList.count - 1, 1) }
                PauseAnimation { duration: spreadContainer.animateIn ? 0 : 140 }
                PropertyAction { target: workspaceSelector; property: "visible" }
                PropertyAction { target: spreadContainer; property: "visible" }
                ParallelAnimation {
                    UbuntuNumberAnimation { target: blurLayer; properties: "saturation,blurRadius"; duration: UbuntuAnimation.SnapDuration }
                    PropertyAction { target: spreadFlickable; property: "visible" }
                    PropertyAction { targets: [currentSelectedLabel,spreadBackground]; property: "visible" }
                    PropertyAction { target: spreadFlickable; property: "contentX"; value: 0 }
                }
                PropertyAction { target: hoverMouseArea; properties: "enabled,progressiveScrollingEnabled"; value: false }
            }
        },
        Transition {
            from: "*"
            to: "*"
            PropertyAnimation { property: "opacity" }
            ScriptAction { script: { root.focusSelected() } }
            PropertyAction { target: spreadRepeater; property: "highlightedIndex"; value: -1 }
            PropertyAction { target: spreadContainer; property: "animateIn"; value: false }
        }
    ]
}
