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
    property alias dragHandleLeftMargin: coverPage.dragHandleLeftMargin
    property alias infographicModel: coverPage.infographicModel
    property alias launcherOffset: coverPage.launcherOffset
    property alias loginListShown: loginList.loginListShown
    property alias currentIndex: loginList.currentIndex
    property int delayMinutes // TODO
    property alias alphanumeric: loginList.alphanumeric
    property alias locked: loginList.locked
    property alias sessionToStart: loginList.currentSession
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

    /***** Functions that depend on LoginList being loaded *****/
    // A decorator to only call LoginList functions when its shown
    function ifLoginlistShownThen(f) {
        return function() {
            if (loginListShown) f.apply(this, arguments);
        }
    }

    readonly property var notifyAuthenticationFailed: ifLoginlistShownThen(doNotifyAuthenticationFailed);
    function doNotifyAuthenticationFailed() {
        loginListm.showError();
    }

    readonly property var reset: ifLoginlistShownThen(doReset);
    function doReset() {
        loginList.reset();
    }

    readonly property var showMessage: ifLoginlistShownThen(doShowMessage);
    function doShowMessage(html) {
        loginList.showMessage(html);
    }

    readonly property var showPrompt: ifLoginlistShownThen(doShowPrompt);
    function doShowPrompt(text, isSecret, isDefaultPrompt) {
        loginList.showPrompt(text, isSecret, isDefaultPrompt);
    }

    readonly property var tryToUnlock: ifLoginlistShownThen(doTryToUnlock);
    function doTryToUnlock(toTheRight) {
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

    /***** Functions that are agnostic of what object is loaded *****/
    function hide() {
        coverPage.hide();
    }

    function notifyAuthenticationSucceeded() {
        // Nothing needed
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

            property bool loginListShown: true
            property bool sessionUpdated: false

            height: inputMethod && inputMethod.visible ?
                parent.height - inputMethod.keyboardRectangle.height : parent.height
            width: units.gu(40)
            anchors {
                left: parent.left
                leftMargin: Math.min(parent.width * 0.16, units.gu(20))
                top: parent.top
            }

            model: root.userModel

            currentSession: LightDMService.greeter.defaultSession
            onResponded: root.responded(response)
            onSelected: root.selected(index)
            onSessionChooserButtonClicked: parent.state = "SessionsList"
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

            Binding {
                target: sessionChooserLoader.item
                property: "initiallySelectedSession"
                value: loginList.currentSession
            }

            Connections {
                target: sessionChooserLoader.item
                onShowLoginList: coverPage.state = "LoginList"
                onSessionSelected: {
                    loginList.sessionUpdated = true
                    loginList.currentSession = sessionKey
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

        /*Loader {
            id: loginList
            objectName: "loginList"

            // True when LoginList is shown, false when SessionList is shown
            property bool loginListShown: true
            property bool sessionUpdated: false
            property string currentSession: LightDMService.sessions.defaultSession // Set as soon as LoginList is loaded

            source: loginListShown ? "LoginList.qml" : "SessionsList.qml"
            onSourceChanged: loadingAnimation.running = true

            anchors {
                left: parent.left
                leftMargin: Math.min(parent.width * 0.16, units.gu(20))
                top: parent.top
            }

            width: units.gu(40)
            height: inputMethod && inputMethod.visible ?
                parent.height - inputMethod.keyboardRectangle.height : parent.height

            UbuntuNumberAnimation {
                id: loadingAnimation
                target: loginList.item
                property: "opacity"
                from: 0
                to: 1
                running: false
            }

            Binding {
                target: loginList.item
                property: "alphanumeric"
                value: loginListShown ? root.alphanumeric : null
            }

            Binding {
                target: loginList.item
                property: "currentIndex"
                value: loginListShown ? root.currentIndex : null
            }

            Binding {
                target: loginList.item
                property: "locked"
                value: root.locked
            }

            Binding {
                target: loginList.item
                property: "model"
                value: loginListShown ? root.userModel : null
            }

            // Only inform LoginList if the session isn't the user's default session
            // because LoginList gets the default session on its own
            Binding {
                target: loginList.item
                property: "selectedSession"
                value: loginListShown && loginList.sessionUpdated ?
                    loginList.currentSession : null
            }

            Binding {
                target: loginList.item
                property: "initiallySelectedSession"
                value: !loginListShown ? loginList.currentSession : null
            }

            Connections {
                target: loginListShown ? loginList.item : null
                onSelected: root.selected(index)
                onResponded: root.responded(response)
                // The initially selected session lags behind the component completion
                // so this provides the initial session name when available
                onLoginListSessionChanged: {
                    if (loginListShown && !loginList.sessionUpdated) {
                        loginList.currentSession = loginList.item.currentSession
                    }
                }

                onSessionChooserButtonClicked: loginListShown = false;
                ignoreUnknownSignals: true
            }

            Connections {
                target: !loginListShown ? loginList.item : null
                onSessionSelected: {
                    loginList.sessionUpdated = true
                    loginList.currentSession = sessionKey
                }

                onShowLoginList: loginList.loginListShown = true
                ignoreUnknownSignals: true
            }
        }*/
    }
}
