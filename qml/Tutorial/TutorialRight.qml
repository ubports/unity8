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
import Ubuntu.Gestures 0.1
import Unity.Application 0.1
import "../Components"
import "../Stages"
import "." as LocalComponents

TutorialPage {
    id: root

    property var panel
    property alias edgeSize: stage.dragAreaWidth

    title: i18n.tr("To view open apps")
    text: i18n.tr("Long swipe from the right edge.")

    textOpacity: 1 - slider.percent

    SequentialAnimation {
        id: teaseAnimation
        paused: running && root.paused
        running: !stage.dragging && stage.dragProgress === 0
        loops: Animation.Infinite

        UbuntuNumberAnimation {
            target: stage
            property: "x"
            to: -units.gu(2)
            duration: UbuntuAnimation.SleepyDuration
        }
        UbuntuNumberAnimation {
            target: stage
            property: "x"
            to: 0
            duration: UbuntuAnimation.SleepyDuration
        }
    }

    foreground {
        children: [
            LocalComponents.Slider {
                id: slider
                anchors {
                    right: parent.right
                    top: parent.top
                    topMargin: root.textBottom + units.gu(3)
                }
                rotation: 180
                offset: stage.dragProgress - stage.x
                active: stage.dragging
            },

            // Just assume PhoneStage for now.  The tablet version of the right-edge
            // tutorial is still being spec'd by the design team.
            PhoneStage {
                id: stage
                objectName: "stage"
                anchors.top: parent.top
                width: parent.width
                height: parent.height
                applicationManager: fakeAppManager
                color: "transparent"
                interactive: false
                altTabEnabled: false
                focusFirstApp: false
                startScale: 0.8
                endScale: 0.6
                dragAreaOverlap: -x

                onOpened: {
                    overlay.show();
                    root.textOpacity = 0;
                    slider.visible = false;
                }

                onDraggingChanged: {
                    if (!dragging) {
                        if (!overlay.shown) {
                            root.showError();
                        }
                        teaseAnimation.complete();
                    }
                }
            },

            Showable {
                id: overlay
                objectName: "overlay"
                anchors.fill: parent

                opacity: 0
                shown: false
                showAnimation: UbuntuNumberAnimation { property: "opacity"; to: 1 }

                Label {
                    anchors.top: parent.top
                    anchors.topMargin: root.panel.panelHeight + units.gu(2)
                    anchors.left: parent.left
                    anchors.leftMargin: units.gu(2)
                    anchors.right: parent.right
                    anchors.rightMargin: units.gu(2)
                    wrapMode: Text.Wrap
                    horizontalAlignment: Text.AlignHCenter
                    fontSize: "large"
                    text: i18n.tr("View all your running tasks.")
                }

                LocalComponents.Tick {
                    objectName: "tick"
                    anchors.bottom: bottomOverlayText.top
                    anchors.bottomMargin: units.gu(1)
                    anchors.horizontalCenter: bottomOverlayText.horizontalCenter
                    onClicked: root.hide()
                }

                Label {
                    id: bottomOverlayText
                    anchors.bottom: parent.bottom
                    anchors.bottomMargin: units.gu(2)
                    anchors.left: parent.left
                    anchors.leftMargin: units.gu(2)
                    anchors.right: parent.right
                    anchors.rightMargin: units.gu(2)
                    wrapMode: Text.Wrap
                    horizontalAlignment: Text.AlignHCenter
                    fontSize: "small"
                    text: i18n.tr("Tap here to continue.")
                }
            }
        ]
    }

    ListModel {
        id: fakeAppManager

        readonly property string focusedApplicationId: "facebook"

        function focusApplication(appId) {}
        function requestFocusApplication(appId) {}
        function findApplication(appId) {return null;}

        signal applicationAdded(string appId)
        signal applicationRemoved(string appId)
        signal focusRequested(string appId)

        ListElement {
            appId: "facebook"
            fullscreen: false
            name: ""
            icon: ""
            state: ApplicationInfoInterface.Stopped
            splashTitle: ""
            splashImage: ""
            splashShowHeader: false
            splashColor: "transparent"
            splashColorHeader: "transparent"
            splashColorFooter: "transparent"
            defaultScreenshot: "../Tutorial/graphics/facebook.png"
        }

        ListElement {
            appId: "camera"
            fullscreen: false
            name: ""
            icon: ""
            state: ApplicationInfoInterface.Stopped
            splashTitle: ""
            splashImage: ""
            splashShowHeader: false
            splashColor: "transparent"
            splashColorHeader: "transparent"
            splashColorFooter: "transparent"
            defaultScreenshot: "../Tutorial/graphics/camera.png"
        }

        ListElement {
            appId: "gallery"
            fullscreen: false
            name: ""
            icon: ""
            state: ApplicationInfoInterface.Stopped
            splashTitle: ""
            splashImage: ""
            splashShowHeader: false
            splashColor: "transparent"
            splashColorHeader: "transparent"
            splashColorFooter: "transparent"
            defaultScreenshot: "../Tutorial/graphics/gallery.png"
        }

        ListElement {
            appId: "dialer"
            fullscreen: false
            name: ""
            icon: ""
            state: ApplicationInfoInterface.Stopped
            splashTitle: ""
            splashImage: ""
            splashShowHeader: false
            splashColor: "transparent"
            splashColorHeader: "transparent"
            splashColorFooter: "transparent"
            defaultScreenshot: "../Tutorial/graphics/dialer.png"
        }
    }
}
