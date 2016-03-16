/*
 * Copyright (C) 2015 Canonical, Ltd.
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
import Unity.Application 0.1

TutorialPage {
    id: root

    property string usageScenario
    property var stage
    property var application: null

    // This page is a bit fragile.  It relies on knowing how the app beneath
    // the shell will react to a drag.  What we do is put a monitor-only DDA
    // at the bottom of the page (so that we know when the drag is finished)
    // and pass the events on through to the app.  Thus, it sees the drag and
    // brings its bottom edge up.
    //
    // Unfortunately, each app is on its own when implementing the bottom edge
    // drag.  Most share copied-and-pasted code right now, but they will
    // eventually consolidate on a version of DirectionalDragArea that will
    // land in the SDK (making our guessing job easier).  Though, also in the
    // future, this whole bottom tutorial component will also land in the SDK,
    // rendering our version here obsolete.
    //
    // Anyway, for the moment, we base our guesses on the copied-and-pasted
    // code used in several of the core apps and only bring this component
    // up if we are in those core apps.

    readonly property real mainStageWidth: stage.width - sideStageWidth
    readonly property real sideStageWidth: root.usageScenario === "tablet" && stage.sideStageVisible ?
                                           stage.sideStageWidth : 0
    readonly property bool isMainStageApp: usageScenario !== "tablet" ||
                                           application.stage === ApplicationInfoInterface.MainStage
    readonly property real dragAreaHeight: units.gu(3) // based on PageWithBottomEdge.qml
    readonly property real targetDistance: height * 0.2 + dragAreaHeight // based on PageWithBottomEdge.qml

    opacityOverride: dragArea.dragging ? 1 - (-dragArea.distance / targetDistance) : 1

    mouseArea {
        anchors.bottomMargin: root.dragAreaHeight
    }

    background {
        sourceSize.height: 1916
        sourceSize.width: 1080
        source: Qt.resolvedUrl("graphics/background2.png")
        rotation: 180
    }

    arrow {
        anchors.bottom: root.bottom
        anchors.bottomMargin: units.gu(3)
        anchors.horizontalCenter: label.horizontalCenter
        anchors.horizontalCenterOffset: -(label.width - label.contentWidth) / 2
        rotation: 90
    }

    label {
        text: !application ? "" :
              application.appId === "address-book-app" ?
                                    i18n.tr("Swipe up to add a contact") :
              application.appId === "com.ubuntu.calculator_calculator" ?
                                    i18n.tr("Swipe up for favorite calculations") :
              application.appId === "dialer-app" ?
                                    i18n.tr("Swipe up for recent calls") :
              application.appId === "messaging-app" ?
                                    i18n.tr("Swipe up to create a message") :
              i18n.tr("Swipe up to manage the app") // shouldn't be used
        anchors.bottom: arrow.top
        anchors.bottomMargin: units.gu(3)
        anchors.left: root.left
        anchors.leftMargin: (label.width - label.contentWidth) / 2 + sideMargin +
                            (isMainStageApp ? 0 : mainStageWidth)
        width: (isMainStageApp ? mainStageWidth : sideStageWidth) - sideMargin * 2

        readonly property real sideMargin: units.gu(4)
    }

    // Watches drag events but does not intercept them, so that the app beneath
    // will still drag the bottom edge up.
    DirectionalDragArea {
        id: dragArea
        monitorOnly: true
        direction: Direction.Upwards
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.bottom: parent.bottom
        height: root.dragAreaHeight

        // Apps currently don't use DDA.  DDA will stop a gesture if
        // horizontal motion is detected.  But our apps won't.  So turn off
        // that gesture cleverness on our part, it will only get us out of sync.
        immediateRecognition: true
    }

    MouseArea {
        // A second mouse area because in tablet mode, we only want to let the
        // user drag up on one of the stages, not both.  So we want to cover
        // the second bottom edge with an event eater.
        enabled: root.usageScenario === "tablet"
        height: root.dragAreaHeight
        width: isMainStageApp ? sideStageWidth : mainStageWidth
        anchors.bottom: parent.bottom
        anchors.left: isMainStageApp ? undefined : parent.left
        anchors.right: isMainStageApp ? parent.right : undefined
    }
}
