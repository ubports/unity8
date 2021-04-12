/*
 * Copyright 2014-2016 Canonical Ltd.
 *
 * This program is free software; you can redistribute it and/or modify
 * it under the terms of the GNU Lesser General Public License as published by
 * the Free Software Foundation; version 3.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
 * GNU Lesser General Public License for more details.
 *
 * You should have received a copy of the GNU Lesser General Public License
 * along with this program. If not, see <http://www.gnu.org/licenses/>.
 */

import QtQuick 2.4
import Lomiri.Components 1.3
import Unity.Application 0.1

FocusScope {
    id: root
    implicitWidth: requestedWidth
    implicitHeight: requestedHeight

    // to be read from outside
    property alias interactive: surfaceContainer.interactive
    property bool orientationChangesEnabled: d.supportsSurfaceResize ? d.surfaceOldEnoughToBeResized : true
    readonly property string title: surface && surface.name !== "" ? surface.name : d.name
    readonly property QtObject focusedSurface: d.focusedSurface.surface
    readonly property alias surfaceInitialized: d.surfaceInitialized

    // to be set from outside
    property QtObject surface
    property QtObject application
    property int surfaceOrientationAngle
    property int requestedWidth: -1
    property int requestedHeight: -1
    property real splashRotation: 0

    readonly property int minimumWidth: surface ? surface.minimumWidth : 0
    readonly property int minimumHeight: surface ? surface.minimumHeight : 0
    readonly property int maximumWidth: surface ? surface.maximumWidth : 0
    readonly property int maximumHeight: surface ? surface.maximumHeight : 0
    readonly property int widthIncrement: surface ? surface.widthIncrement : 0
    readonly property int heightIncrement: surface ? surface.heightIncrement : 0

    onSurfaceChanged: {
        // The order in which the instructions are executed here matters, to that the correct state
        // transitions in stateGroup take place.
        // More specifically, the moment surfaceContainer.surface gets updated relative to the
        // other instructions.
        if (surface) {
            surfaceContainer.surface = surface;
            surfaceInitTimer.start();
        } else {
            d.surfaceInitialized = false;
            surfaceContainer.surface = null;
        }
    }

    QtObject {
        id: d

        // helpers so that we don't have to check for the existence of an application everywhere
        // (in order to avoid breaking qml binding due to a javascript exception)
        readonly property string name: root.application ? root.application.name : ""
        readonly property url icon: root.application ? root.application.icon : ""
        readonly property int applicationState: root.application ? root.application.state : -1
        readonly property string splashTitle: root.application ? root.application.splashTitle : ""
        readonly property url splashImage: root.application ? root.application.splashImage : ""
        readonly property bool splashShowHeader: root.application ? root.application.splashShowHeader : true
        readonly property color splashColor: root.application ? root.application.splashColor : "#00000000"
        readonly property color splashColorHeader: root.application ? root.application.splashColorHeader : "#00000000"
        readonly property color splashColorFooter: root.application ? root.application.splashColorFooter : "#00000000"

        // Whether the Application had a surface before but lost it.
        property bool hadSurface: false

        //FIXME - this is a hack to avoid the first few rendered frames as they
        // might show the UI accommodating due to surface resizes on startup.
        // Remove this when possible
        property bool surfaceInitialized: false

        readonly property bool supportsSurfaceResize:
                application &&
                ((application.supportedOrientations & Qt.PortraitOrientation)
                  || (application.supportedOrientations & Qt.InvertedPortraitOrientation))
                &&
                ((application.supportedOrientations & Qt.LandscapeOrientation)
                 || (application.supportedOrientations & Qt.InvertedLandscapeOrientation))

        property bool surfaceOldEnoughToBeResized: false

        property Item focusedSurface: promptSurfacesRepeater.count === 0 ? surfaceContainer
                                                                         : promptSurfacesRepeater.first
        onFocusedSurfaceChanged: {
            if (focusedSurface) {
                focusedSurface.focus = true;
            }
        }
    }

    Binding {
        target: root.application
        property: "initialSurfaceSize"
        value: Qt.size(root.requestedWidth, root.requestedHeight)
    }

    Timer {
        id: surfaceInitTimer
        interval: 100
        onTriggered: {
            if (root.surface && root.surface.live) {
                d.surfaceInitialized = true;
                d.hadSurface = true;
                d.surfaceOldEnoughToBeResized = true;
            }
        }
    }

    Loader {
        id: splashLoader
        visible: active
        active: false
        anchors.fill: parent
        z: 1
        sourceComponent: Component {
            Splash {
                id: splash
                title: d.splashTitle ? d.splashTitle : d.name
                imageSource: d.splashImage
                icon: d.icon
                showHeader: d.splashShowHeader
                backgroundColor: d.splashColor
                headerColor: d.splashColorHeader
                footerColor: d.splashColorFooter

                rotation: root.splashRotation
                anchors.centerIn: parent
                width: rotation == 0 || rotation == 180 ? root.width : root.height
                height: rotation == 0 || rotation == 180 ? root.height : root.width
            }
        }
    }

    SurfaceContainer {
        id: surfaceContainer
        anchors.fill: parent
        z: splashLoader.z + 1
        requestedWidth: root.requestedWidth
        requestedHeight: root.requestedHeight
        surfaceOrientationAngle: application && application.rotatesWindowContents ? root.surfaceOrientationAngle : 0
    }

    Repeater {
        id: promptSurfacesRepeater
        objectName: "promptSurfacesRepeater"
        // show only along with the top-most application surface
        model: {
            if (root.application && (
                    root.surface === root.application.surfaceList.first ||
                    root.application.surfaceList.count === 0)) {
                return root.application.promptSurfaceList;
            } else {
                return null;
            }
        }
        delegate: SurfaceContainer {
            id: promptSurfaceContainer
            interactive: index === 0 && root.interactive
            surface: model.surface
            width: root.width
            height: root.height
            requestedWidth: root.requestedWidth
            requestedHeight: root.requestedHeight
            isPromptSurface: true
            z: surfaceContainer.z + (promptSurfacesRepeater.count - index)
            property int index: model.index
            onIndexChanged: updateFirst()
            Component.onCompleted: updateFirst()
            function updateFirst() {
                if (index === 0) {
                    promptSurfacesRepeater.first = promptSurfaceContainer;
                }
            }
        }
        onCountChanged: {
            if (count === 0) {
                first = null;
            }
        }
        property Item first: null
    }

    StateGroup {
        id: stateGroup
        objectName: "applicationWindowStateGroup"
        states: [
            State{
                name: "surface"
                when: (root.surface && d.surfaceInitialized) || d.hadSurface
            },
            State {
                name: "splash"
                when: !root.surface && !d.surfaceInitialized && !d.hadSurface
                PropertyChanges { target: splashLoader; active: true }
            }
        ]
    }
}
