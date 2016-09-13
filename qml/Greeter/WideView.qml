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
import Ubuntu.Components 1.3
import "." 0.1

FocusScope {
    id: root
    focus: true

    property alias background: coverPage.background
    property alias backgroundTopMargin: coverPage.backgroundTopMargin
    property alias hasCustomBackground: coverPage.hasCustomBackground
    property alias dragHandleLeftMargin: coverPage.dragHandleLeftMargin
    property alias infographicModel: coverPage.infographicModel
    property alias launcherOffset: coverPage.launcherOffset
    property alias currentIndex: loginList.currentIndex
    property int delayMinutes // TODO
    property alias alphanumeric: loginList.alphanumeric
    property alias locked: loginList.locked
    property alias sessionToStart: loginList.currentSession
    property alias waiting: loginList.waiting
    property var userModel // Set from outside

    readonly property bool animating: coverPage.showAnimation.running || coverPage.hideAnimation.running
    readonly property bool fullyShown: coverPage.showProgress === 1
    readonly property bool required: coverPage.required

    // so that it can be replaced in tests with a mock object
    property var inputMethod: Qt.inputMethod

    signal selected(int index)
    signal responded(string response)
    signal tease()
    signal emergencyCall() // unused

    function notifyAuthenticationFailed() {
        loginList.showError();
    }

    function reset(forceShow) {
        loginList.reset();
    }

    function showMessage(html) {
        loginList.showMessage(html);
    }

    function showPrompt(text, isSecret, isDefaultPrompt) {
        loginList.showPrompt(text, isSecret, isDefaultPrompt);
    }

    function tryToUnlock(toTheRight) {
        if (root.locked) {
            coverPage.show();
            loginList.tryToUnlock();
            return false;
        } else {
            var coverChanged = coverPage.shown;
            if (toTheRight) {
                coverPage.hideRight();
            } else {
                coverPage.hide();
            }
            return coverChanged;
        }
    }

    function hide() {
        coverPage.hide();
    }

    function notifyAuthenticationSucceeded(showFakePassword) {
        if (showFakePassword) {
            loginList.showFakePassword();
        }
    }

    function showLastChance() {
        // TODO
    }

    Rectangle {
        anchors.fill: parent
        color: "black"
        opacity: coverPage.showProgress * 0.8
    }

    CoverPage {
        id: coverPage
        objectName: "coverPage"
        height: parent.height
        width: parent.width
        draggable: !root.locked && !root.waiting
        state: "LoginList"

        infographics {
            height: 0.75 * parent.height
            anchors.leftMargin: loginList.x + loginList.width
        }

        onTease: root.tease()

        onShowProgressChanged: {
            if (showProgress === 0 && !root.locked) {
                root.responded("");
            }
        }

        LoginList {
            id: loginList
            objectName: "loginList"

            width: units.gu(40)
            anchors {
                left: parent.left
                leftMargin: Math.min(parent.width * 0.16, units.gu(20))
                top: parent.top
                bottom: parent.bottom
            }

            boxVerticalOffset: (height - highlightedHeight -
                               (inputMethod && inputMethod.visible ?
                                inputMethod.keyboardRectangle.height : 0)) / 2
            Behavior on boxVerticalOffset { UbuntuNumberAnimation {} }

            model: root.userModel
            currentSession: LightDMService.greeter.defaultSession
            onResponded: root.responded(response)
            onSelected: root.selected(index)
            onSessionChooserButtonClicked: parent.state = "SessionsList"

            Keys.forwardTo: [sessionChooserLoader.item]
        }

        Loader {
            id: sessionChooserLoader

            height: loginList.height
            width: loginList.width
            anchors {
                left: parent.left
                leftMargin: Math.min(parent.width * 0.16, units.gu(20))
                top: parent.top
            }

            active: false

            onLoaded: sessionChooserLoader.item.forceActiveFocus();
            Binding {
                target: sessionChooserLoader.item
                property: "initiallySelectedSession"
                value: loginList.currentSession
            }

            Connections {
                target: sessionChooserLoader.item
                onSessionSelected: loginList.currentSession = sessionKey
                onShowLoginList: {
                    coverPage.state = "LoginList"
                    loginList.passwordInput.forceActiveFocus();
                }
                ignoreUnknownSignals: true
            }
        }

        states: [
            State {
                name: "SessionsList"
                PropertyChanges { target: loginList; opacity: 0 }
                PropertyChanges { target: sessionChooserLoader;
                                  active: true;
                                  opacity: 1
                                  source: "SessionsList.qml"
                                }
            },

            State {
                name: "LoginList"
                PropertyChanges { target: loginList; opacity: 1 }
                PropertyChanges { target: sessionChooserLoader;
                                  active: false;
                                  opacity: 0
                                  source: "";
                                }
            }
        ]

        transitions: [
            Transition {
                from: "*"
                to: "*"
                UbuntuNumberAnimation {
                    property: "opacity";
                }
            }
        ]
    }
}
