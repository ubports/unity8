/*
 * Copyright (C) 2012, 2013 Canonical, Ltd.
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

import QtQuick 2.0
import Ubuntu.Components 0.1
import HudClient 0.1

import "../Components"
import "../Components/Flickables" as Flickables

Item {
    id: hud

    readonly property real elementsPadding: units.gu(1)
    readonly property real elementsYSliding: units.gu(2)

    property alias revealerTarget: hudShowable
    property alias showAnimation: hudShowable.showAnimation
    property alias hideAnimation: hudShowable.hideAnimation
    property alias available: hudShowable.available
    property alias shown: hudShowable.shown
    property alias handleHeight: handle.height

    readonly property variant outEasing: Easing.OutQuad
    readonly property variant inEasing: Easing.InQuad
    readonly property int animationDuration: 200
    readonly property int showableAnimationDuration: 100
    property bool showingOpenIndicator: false

    // FIXME At the moment since we have no appstack
    // it's not possible to get results of the sidestage app
    // design has to come up with a solution
    function show() {
        hudShowable.show()
    }
    function hide() {
        hudShowable.hide()
    }
    function resetToInitialState() {
        hud.state = "initial"
        searchBar.unfocus()
        searchBar.text = ""
        parametrizedActionsPage.shown = false
    }

    states: [
        State {
            name: "initial"
            PropertyChanges { target: searchBar; placeholderText: i18n.tr("Type or say a command") }
            PropertyChanges { target: searchBar; searchEnabled: true }
            PropertyChanges { target: toolBarAnimator; visible: true}
            AnchorChanges { target: searchBarAnimator; anchors.top: undefined; anchors.bottom: parent.bottom; }
            AnchorChanges { target: resultsCardAnimator; anchors.top: undefined; anchors.bottom: toolBarAnimator.top; }
        },
        State {
            name: "input" //only inherited by other states.
            AnchorChanges { target: searchBarAnimator; anchors.top: parent.top; anchors.bottom: undefined; }
            AnchorChanges { target: resultsCardAnimator; anchors.top: searchBarAnimator.bottom; anchors.bottom: undefined; }
            PropertyChanges { target: toolBarAnimator; visible: false }
        },
        State {
            name: "voice_input" //only inherited by other states.
            extend: "input"
            PropertyChanges { target: soundAmplitudeVisualAnimator; visible: true }
            PropertyChanges { target: resultsCardAnimator; visible: false }
            PropertyChanges { target: soundAmplitudeVisualAnimator; progress: 1 }
            PropertyChanges { target: searchBar; searchEnabled: false }
        },
        State {
            name: "voice_recognition_loading"
            extend: "voice_input"
            PropertyChanges { target: searchBar; placeholderText: i18n.tr("Loading. Please Wait...") }
        },
        State {
            name: "voice_recognition_listening"
            extend: "voice_input"
            PropertyChanges { target: searchBar; placeholderText: i18n.tr("Speak Now...") }
        },
        State {
            name: "voice_recognition_processing"
            extend: "voice_input"
            PropertyChanges { target: searchBar; placeholderText: i18n.tr("Speaking...") }
        },
        State {
            name: "showing_results"
            extend: "input"
            PropertyChanges { target: searchBar; placeholderText: i18n.tr("Type or say a command") }
            PropertyChanges { target: searchBar; searchEnabled: true }
        }
    ]

    transitions: [
        Transition {
            from: "initial"
            to: "voice_recognition_loading"
            SequentialAnimation {
                NumberAnimation { // hide these components
                    targets: [toolBarAnimator, searchBarAnimator, resultsCardAnimator]
                    property: "progress"; duration: animationDuration; to: 0
                }

                PropertyAction { targets: [toolBarAnimator, resultsCardAnimator]; property: "visible"; value: false}
                PropertyAction { target: soundAmplitudeVisualAnimator; property: "visible"; value: true}

                AnchorAnimation { duration: 0 } // so anchor change happens at this point

                NumberAnimation { // show these components
                    targets: [searchBarAnimator, soundAmplitudeVisualAnimator]
                    property: "progress"; duration: animationDuration; from: 0; to: 1
                }
            }
        },
        Transition {
            from: "showing_results"
            to: "voice_recognition_loading"
            SequentialAnimation {
                PropertyAction { target: soundAmplitudeVisualAnimator; property: "progress"; value: 0}

                PropertyAction { // hide these components
                    target: resultsCardAnimator; property: "progress"; value: 0
                }

                NumberAnimation { // show these components
                    target: soundAmplitudeVisualAnimator; property: "progress"; duration: animationDuration; from: 0; to: 1
                }
            }
        },
        Transition {
            from: "voice_recognition_processing"
            to: "showing_results"
            SequentialAnimation {
                NumberAnimation { // hide these components
                    target: soundAmplitudeVisualAnimator; property: "progress"; duration: animationDuration; to: 0
                }
                PropertyAction { target: resultsCardAnimator; property: "visible"; value: true}

                NumberAnimation { // show these components
                    target: resultsCardAnimator; property: "progress"; duration: animationDuration; from: 0; to: 1
                }
            }
        },
        Transition {
            from: "initial"
            to: "showing_results"
            SequentialAnimation {
                NumberAnimation {
                    targets: [toolBarAnimator, searchBarAnimator, resultsCardAnimator]
                    property: "progress"; duration: animationDuration; to: 0
                }

                PropertyAction { target: toolBarAnimator; property: "visible"; value: false}

                AnchorAnimation { duration: 0 } // so anchor change happens at this point

                NumberAnimation {
                    targets: [searchBarAnimator, resultsCardAnimator]
                    property: "progress"; duration: animationDuration; from: 0; to: 1
                }
            }
        }
    ]

    state: "initial"

    HudClient {
        id: hudClient

        onCommandExecuted: {
            hudShowable.hide()
        }

        onShowParametrizedAction: {
            parametrizedActionsPage.header = action
            parametrizedActionsPage.setItems(items)
            parametrizedActionsPage.shown = true
        }

        onVoiceQueryLoading: {
            hud.state = "voice_recognition_loading"
            searchBar.ignoreNextTextChange = true
            searchBar.text = ""
            searchBar.unfocus()
            soundAmplitudeVisual.startIdle()
        }
        onVoiceQueryListening: {
            if (hud.state == "voice_recognition_loading" || hud.state == "showing_results") {
                searchBar.ignoreNextTextChange = true
                searchBar.text = ""
                searchBar.unfocus()
                hud.state = "voice_recognition_listening"
            }
        }
        onVoiceQueryHeardSomething: {
            if (hud.state == "voice_recognition_listening") {
                hud.state = "voice_recognition_processing"
                soundAmplitudeVisual.setDetectorEnabled(true)
            }
        }
        onVoiceQueryFinished: {
            hud.state = "showing_results"
            searchBar.text = query
            soundAmplitudeVisual.setDetectorEnabled(false)
        }
        onVoiceQueryFailed: {
            hud.state = "showing_results"
            searchBar.text = ""
            soundAmplitudeVisual.setDetectorEnabled(false)
        }
    }

    Showable {
        id: hudShowable
        objectName: "hudShowable"
        height: parent.height
        width: parent.width

        onYChanged: {
            if (greeter.shown) {
                showAnimation.duration = 0
                hideAnimation.duration = 0
            } else if (!showAnimation.running && !hideAnimation.running) {
                if (parent.height > 0) {
                    showAnimation.duration = Math.min(showableAnimationDuration * (1 - (parent.height - y) / parent.height), showableAnimationDuration)
                    hideAnimation.duration = showableAnimationDuration - showAnimation.duration
                }
            }
        }

        MouseArea {
            // Eat everything that doesn't go to other places
            anchors.fill: parent
        }

        Image {
            anchors.fill: parent
            fillMode: Image.Tile
            source: "graphics/hud_bg.png"
        }

        Connections {
            target: hideAnimation
            onRunningChanged: {
                if (!hideAnimation.running) {
                    showAnimation.duration = showableAnimationDuration
                    hud.resetToInitialState()
                }
            }
        }

        Connections {
            target: showAnimation
            onRunningChanged: {
                if (!showAnimation.running) {
                    hideAnimation.duration = showableAnimationDuration
                }
            }
        }
    }

    Item {
        id: handle
        objectName: "handle"

        y: hudShowable.y
        anchors {
            left: parent.left
            right: parent.right
        }
        height: handleImage.height

        Image {
            id: handleImage
            anchors {
                left: parent.left
                right: parent.right
            }
            source: "graphics/hud_handlebar.png"
        }

        Image {
            id: handleArrow
            y: units.gu(1)
            anchors.horizontalCenter: parent.horizontalCenter
            source: "graphics/hud_handlearrow.png"
            cache: false
        }
    }

    Item {
        id: hudContentClipper

        anchors {
            left: parent.left
            right: parent.right
            bottom: parent.bottom
            top: handle.bottom
        }
        clip: visible && hudContent.height !== height
        visible: hudContent.height >= 0

        Item {
            id: hudContent
            anchors {
                left: parent.left
                right: parent.right
                bottom: parent.bottom
            }
            height: hud.height

            Item {
                id: mainPage
                x: parametrizedActionsPage.x - width
                height: hud.height
                width: hud.width

                ShowingAnimation {
                    id: toolBarAnimator
                    objectName: "toolBarAnimator"
                    anchors {
                        left: parent.left
                        right: parent.right
                        bottom: searchBarAnimator.top
                        margins: 2*elementsPadding //ensures positioning correct
                    }
                    progress: MathUtils.clamp((y - hudShowable.y - anchors.margins)/elementsYSliding, 0, 1)

                    ToolBar {
                        id: toolBar
                        objectName: "toolBar"
                        model: hudClient.toolBarModel
                        anchors.horizontalCenter: parent.horizontalCenter
                        onActionTriggered: {
                            hudClient.executeToolBarAction(action)
                        }
                    }
                }

                ShowingAnimation {
                    id: searchBarAnimator
                    objectName: "searchBarAnimator"
                    anchors {
                        left: parent.left
                        right: parent.right
                        bottom: parent.bottom
                        margins: elementsPadding
                        topMargin: handle.height + units.dp(1) + elementsPadding
                    }
                    progress: MathUtils.clamp((y - hudShowable.y - anchors.margins)/elementsYSliding, 0, 1)

                    SearchBar {
                        id: searchBar
                        objectName: "searchBar"

                        property bool ignoreNextTextChange: false

                        anchors.left: parent.left
                        anchors.right: parent.right
                        height: units.gu(5)

                        placeholderText: i18n.tr("Type or say a command")
                        activityIndicatorVisible: hud.state == "voice_recognition_processing"

                        onMicrophoneClicked: hudClient.startVoiceQuery()

                        onTextChanged: {
                            if (ignoreNextTextChange) {
                                ignoreNextTextChange = false
                            } else {
                                hudClient.setQuery(searchBar.text)
                            }
                        }

                        onTextFocused: {
                            hud.state = "showing_results"
                        }
                    }
                }

                ShowingAnimation {
                    id: resultsCardAnimator
                    objectName: "resultsCardAnimator"

                    anchors {
                        left: parent.left
                        right: parent.right
                        top: searchBarAnimator.bottom
                        margins: elementsPadding
                    }
                    progress: MathUtils.clamp((y - hudShowable.y + height - units.gu(8))/elementsYSliding, 0, 1)

                    Flickables.Flickable {
                        anchors.left: parent.left
                        anchors.right: parent.right
                        contentHeight: resultList.height
                        contentWidth: width
                        clip: height < contentHeight
                        interactive: height < contentHeight

                        height: {
                            if (hud.state == "showing_results") {
                                return shell.applicationManager.keyboardVisible ? Math.min(hud.height - searchBarAnimator.y - searchBarAnimator.height - units.gu(2) - shell.applicationManager.keyboardHeight, contentHeight) : contentHeight
                            } else {
                                return contentHeight
                            }
                        }


                        ResultList {
                            id: resultList

                            anchors.left: parent.left
                            anchors.right: parent.right
                            height: childrenRect.height

                            onActivated: {
                                hudClient.executeCommand(index)
                            }

                            model: hudClient.results
                        }
                    }
                }

                ShowingAnimation {
                    id: soundAmplitudeVisualAnimator

                    anchors {
                        horizontalCenter: parent.horizontalCenter
                        verticalCenter: parent.verticalCenter
                        verticalCenterOffset: (searchBar.height + 2*elementsPadding)/2
                    }
                    visible: false
                    width: units.gu(33)
                    progress: MathUtils.clamp((y - hudShowable.y - anchors.verticalCenterOffset)/elementsYSliding, 0, 1)

                    SoundAmplitudeVisual {
                        id: soundAmplitudeVisual
                        width: units.gu(33)
                        height: width
                    }
                }
            }

            HudParametrizedActionsPage {
                id: parametrizedActionsPage
                objectName: "parametrizedActionsPage"
                property bool shown: false

                anchors.bottom: parent.bottom
                height: hud.height - handle.height - units.dp(1)
                width: parent.width
                x: shown ? 0 : width
                onConfirmPressed: {
                    hudClient.executeParametrizedAction(values())
                }
                onValuesUpdated: {
                    hudClient.updateParametrizedAction(values())
                }
                onBackPressed: {
                    shown = false
                }
                onShownChanged: {
                    if (!shown) {
                        hudClient.cancelParametrizedAction()
                    }
                }
                Behavior on x {
                    NumberAnimation {
                        easing.type: outEasing
                        duration: animationDuration
                    }
                }
            }
        }
    }

    Image {
        anchors.left: hudContentClipper.right
        anchors.top: hudContentClipper.top
        anchors.bottom: hudContentClipper.bottom
        fillMode: Image.Tile
        source: "../graphics/dropshadow_right.png"
    }
}
