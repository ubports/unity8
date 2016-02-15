/*
 * Copyright (C) 2013, 2014 Canonical, Ltd.
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
import Ubuntu.Gestures 0.1
import Unity 0.2
import Utils 0.1
import Unity.DashCommunicator 0.1
import "../Components"

Showable {
    id: dash
    objectName: "dash"

    visible: shown

    Connections {
        target: UriHandler
        onOpened: {
            backToDashContent()
            dashContent.currentScope.performQuery(uris[0])
        }
    }

    property bool windowActive: window.active
    property bool showOverlayScope: false

    DashCommunicatorService {
        objectName: "dashCommunicatorService"
        onSetCurrentScopeRequested: {
            if (!isSwipe || !windowActive || bottomEdgeController.progress != 0 || scopeItem.scope || dashContent.subPageShown) {
                if (bottomEdgeController.progress != 0 && window.active) animate = false;
                dashContent.setCurrentScopeAtIndex(index, animate, true)
                backToDashContent()
            }
        }
    }

    function backToDashContent()
    {
        // Close dash overview and nested temp scopes in it
        if (bottomEdgeController.progress != 0) {
            bottomEdgeController.enableAnimation = window.active;
            bottomEdgeController.progress = 0;
        }
        // Close normal temp scopes (e.g. App Store)
        if (scopeItem.scope) {
            scopeItem.backClicked();
        }
        // Close previews
        if (dashContent.subPageShown) {
            dashContent.closePreview();
        }
    }

    function setCurrentScope(scopeId, animate, reset) {
        var scopeIndex = -1;
        for (var i = 0; i < scopes.count; ++i) {
            if (scopes.getScope(i).id == scopeId) {
                scopeIndex = i;
                break;
            }
        }

        if (scopeIndex == -1) {
            console.warn("No match for scope with id: %1".arg(scopeId))
            return
        }

        dash.showOverlayScope = false;

        dashContent.closePreview();

        if (scopeIndex == dashContent.currentIndex && !reset) {
            // the scope is already the current one
            return
        }

        dashContent.workaroundRestoreIndex = -1;
        dashContent.setCurrentScopeAtIndex(scopeIndex, animate, reset)
    }

    Scopes {
        id: scopes
    }

    QtObject {
        id: bottomEdgeController
        objectName: "bottomEdgeController"

        property alias enableAnimation: progressAnimation.enabled
        property real progress: 0
        Behavior on progress {
            id: progressAnimation
            UbuntuNumberAnimation { }
        }

        onProgressChanged: {
            // FIXME This is to workaround a Qt bug with the model moving the current item
            // when the list is ListView.SnapOneItem and ListView.StrictlyEnforceRange
            // together with the code in DashContent.qml
            if (dashContent.workaroundRestoreIndex != -1) {
                dashContent.currentIndex = dashContent.workaroundRestoreIndex;
                dashContent.workaroundRestoreIndex = -1;
            }
        }
    }

    DashContent {
        id: dashContent

        objectName: "dashContent"
        width: dash.width
        height: dash.height
        scopes: scopes
        visible: x != -width
        x: dash.showOverlayScope ? -width : 0
        onGotoScope: {
            dash.setCurrentScope(scopeId, true, false);
        }
        onOpenScope: {
            scopeItem.scope = scope;
            dash.showOverlayScope = true;
        }
        Behavior on x {
            UbuntuNumberAnimation {
                onRunningChanged: {
                    if (!running && dashContent.x == 0) {
                        scopes.closeScope(scopeItem.scope);
                        scopeItem.scope = null;
                    }
                }
            }
        }

        // This is to avoid the situation where a bottom-edge swipe would bring up the dash overview
        // (as expected) but would also cause the dash content flickable to move a bit, because
        // that flickable was getting the touch events while overviewDragHandle was still undecided
        // about whether that touch was indeed performing a directional drag gesture.
        forceNonInteractive: overviewDragHandle.dragging

        enabled: bottomEdgeController.progress == 0
    }

    Rectangle {
        color: "black"
        opacity: bottomEdgeController.progress
        anchors.fill: dashContent
    }

    ScopesList {
        id: scopesList
        objectName: "scopesList"
        width: dash.width
        height: dash.height
        scope: scopes.overviewScope
        y: dash.height * (1 - bottomEdgeController.progress)
        visible: bottomEdgeController.progress != 0
        onBackClicked: {
            bottomEdgeController.enableAnimation = true;
            bottomEdgeController.progress = 0;
        }
        onStoreClicked: {
            bottomEdgeController.enableAnimation = true;
            bottomEdgeController.progress = 0;
            scopesList.scope.performQuery("scope://com.canonical.scopes.clickstore");
        }
        onRequestFavorite: {
            scopes.setFavorite(scopeId, favorite);
        }
        onRequestFavoriteMoveTo: {
            scopes.moveFavoriteTo(scopeId, index);
        }
        onRequestRestore: {
            bottomEdgeController.enableAnimation = true;
            bottomEdgeController.progress = 0;
            dash.setCurrentScope(scopeId, false, false);
        }

        Binding {
            target: scopesList.scope
            property: "isActive"
            value: bottomEdgeController.progress === 1 && (Qt.application.state == Qt.ApplicationActive)
        }

        Connections {
            target: scopesList.scope
            onOpenScope: {
                bottomEdgeController.enableAnimation = true;
                bottomEdgeController.progress = 0;
                scopeItem.scope = scope;
                dash.showOverlayScope = true;
            }
            onGotoScope: {
                bottomEdgeController.enableAnimation = true;
                bottomEdgeController.progress = 0;
                dashContent.gotoScope(scopeId);
            }
        }
    }

    DashBackground {
        anchors.fill: scopeItem
        visible: scopeItem.visible
    }

    GenericScopeView {
        id: scopeItem
        objectName: "dashTempScopeItem"

        x: dash.showOverlayScope ? 0 : width
        y: dashContent.y
        width: parent.width
        height: parent.height
        visible: scope != null
        hasBackAction: true
        isCurrent: visible
        onBackClicked: {
            dash.showOverlayScope = false;
            closePreview();
        }

        Connections {
            target: scopeItem.scope
            onGotoScope: {
                dashContent.gotoScope(scopeId);
            }
            onOpenScope: {
                scopeItem.closePreview();
                var oldScope = scopeItem.scope;
                scopeItem.scope = scope;
                scopes.closeScope(oldScope);
            }
        }

        Behavior on x {
            UbuntuNumberAnimation { }
        }
    }

    Rectangle {
        id: indicator
        objectName: "processingIndicator"
        anchors {
            left: parent.left
            right: parent.right
            bottom: parent.bottom
            bottomMargin: Qt.inputMethod.keyboardRectangle.height
        }
        height: units.dp(3)
        color: scopeStyle.backgroundLuminance > 0.7 ? "#50000000" : "#50ffffff"
        opacity: 0
        visible: opacity > 0

        readonly property bool processing: dashContent.processing || scopeItem.processing || scopesList.processing

        Behavior on opacity {
            UbuntuNumberAnimation { duration: UbuntuAnimation.FastDuration }
        }

        onProcessingChanged: {
            if (processing) delay.start();
            else if (!persist.running) indicator.opacity = 0;
        }

        Timer {
            id: delay
            interval: 200
            onTriggered: if (indicator.processing) {
                persist.restart();
                indicator.opacity = 1;
            }
        }

        Timer {
            id: persist
            interval: 2 * UbuntuAnimation.SleepyDuration - UbuntuAnimation.FastDuration
            onTriggered: if (!indicator.processing) indicator.opacity = 0
        }

        Rectangle {
            id: orange
            anchors { top: parent.top;  bottom: parent.bottom }
            width: parent.width / 4
            color: UbuntuColors.orange

            SequentialAnimation {
                running: indicator.visible
                loops: Animation.Infinite
                XAnimator {
                    from: -orange.width / 2
                    to: indicator.width - orange.width / 2
                    duration: UbuntuAnimation.SleepyDuration
                    easing.type: Easing.InOutSine
                    target: orange
                }
                XAnimator {
                    from: indicator.width - orange.width / 2
                    to: -orange.width / 2
                    duration: UbuntuAnimation.SleepyDuration
                    easing.type: Easing.InOutSine
                    target: orange
                }
            }
        }
    }

    Image {
        objectName: "overviewHint"
        source: "graphics/overview_hint.png"
        anchors.horizontalCenter: parent.horizontalCenter
        opacity: !scopeItem.scope && (scopes.count == 0 || dashContent.pageHeaderTotallyVisible) &&
                 (overviewDragHandle.enabled || bottomEdgeController.progress != 0) ? 1 : 0
        Behavior on opacity {
            enabled: bottomEdgeController.progress == 0
            UbuntuNumberAnimation {}
        }
        y: parent.height - height * (1 - bottomEdgeController.progress * 4)
        MouseArea {
            // Eat direct presses on the overview hint so that they do not end up in the card below
            anchors.fill: parent
            enabled: parent.opacity != 0

            // TODO: This is a temporary workaround to allow people opening the
            // dash overview when there's no touch input around. Will be replaced with
            // a SDK component once that's available
            onClicked: bottomEdgeController.progress = 1;

            // We need to eat touch events here in order to not allow opening the bottom edge with a touch press
            MultiPointTouchArea {
                anchors.fill: parent
                mouseEnabled: false
                enabled: parent.enabled
            }
        }
    }

    DirectionalDragArea {
        id: overviewDragHandle
        objectName: "overviewDragHandle"
        z: 1
        direction: Direction.Upwards
        enabled: !dashContent.subPageShown &&
                  (scopes.count == 0 || (dashContent.currentScope && dashContent.currentScope.searchQuery == "")) &&
                  !scopeItem.scope &&
                  (bottomEdgeController.progress == 0 || dragging)

        readonly property real fullMovement: dash.height

        anchors { left: parent.left; right: parent.right; bottom: parent.bottom }
        height: units.gu(2)

        onSceneDistanceChanged: {
            if (dragging) {
                bottomEdgeController.enableAnimation = false;
                bottomEdgeController.progress = Math.max(0, Math.min(1, sceneDistance / fullMovement));
            }
        }

        onDraggingChanged: {
            if (!dragging) {
                bottomEdgeController.enableAnimation = true;
                bottomEdgeController.progress = (bottomEdgeController.progress > 0.2)  ? 1 : 0;
            }
        }
    }
}
