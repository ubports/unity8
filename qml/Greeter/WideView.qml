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
import "." 0.1

FocusScope {
    id: root

    property alias background: coverPage.background
    property alias backgroundTopMargin: coverPage.backgroundTopMargin
    property alias dragHandleLeftMargin: coverPage.dragHandleLeftMargin
    property alias infographicModel: coverPage.infographicModel
    property alias launcherOffset: coverPage.launcherOffset
    property alias loginListShown: loginAreaLoader.loginListShown
    property int currentIndex // Set from outside
    property int delayMinutes // TODO
    property bool alphanumeric // unused
    property bool locked
    property alias sessionToStart: loginAreaLoader.currentSession
    property var userModel // Set from outside

    readonly property bool animating: coverPage.showAnimation.running || coverPage.hideAnimation.running
    readonly property bool fullyShown: coverPage.showProgress === 1
    readonly property bool required: coverPage.required

    // so that it can be replaced in tests with a mock object
    property var inputMethod: Qt.inputMethod

    signal promptlessLogin()
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
        loginAreaLoader.item.showError();
    }

    readonly property var reset: ifLoginlistShownThen(doReset);
    function doReset() {
        loginAreaLoader.item.reset();
    }

    readonly property var showMessage: ifLoginlistShownThen(doShowMessage);
    function doShowMessage(html) {
        loginAreaLoader.item.showMessage(html);
    }

    readonly property var showPrompt: ifLoginlistShownThen(doShowPrompt);
    function doShowPrompt(text, isSecret, isDefaultPrompt) {
        loginAreaLoader.item.showPrompt(text, isSecret, isDefaultPrompt);
    }

    readonly property var tryToUnlock: ifLoginlistShownThen(doTryToUnlock);
    function doTryToUnlock(toTheRight) {
        if (root.locked) {
            coverPage.show();
            loginAreaLoader.item.tryToUnlock();
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
        draggable: !root.locked

        infographics {
            height: 0.75 * parent.height
            anchors.leftMargin: loginAreaLoader.x + loginAreaLoader.width
        }

        onTease: root.tease()

        onShowProgressChanged: {
            if (showProgress === 0 && !root.locked) {
                root.responded("");
            }
        }

        Loader {
            id: loginAreaLoader
            objectName: "loginAreaLoader"

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

            width: units.gu(29)
            height: inputMethod && inputMethod.visible ?
                parent.height - inputMethod.keyboardRectangle.height : parent.height

            Behavior on height { UbuntuNumberAnimation {} }

            UbuntuNumberAnimation {
                id: loadingAnimation
                target: loginAreaLoader.item
                property: "x"
                from: loader.item ? loader.item.width : 0
                to: 0
                running: false
            }

            Binding {
                target: loginAreaLoader.item
                property: "currentIndex"
                value: loginListShown ? root.currentIndex : null
            }

            Binding {
                target: loginAreaLoader.item
                property: "locked"
                value: root.locked
            }

            Binding {
                target: loginAreaLoader.item
                property: "model"
                value: loginListShown ? root.userModel : null
            }

            // Only inform LoginList if the session isn't the user's default session
            // because LoginList gets the default session on its own
            Binding {
                target: loginAreaLoader.item
                property: "selectedSession"
                value: loginListShown && loginAreaLoader.sessionUpdated ?
                    loginAreaLoader.currentSession : null
            }

            Binding {
                target: loginAreaLoader.item
                property: "initiallySelectedSession"
                value: !loginListShown ? loginAreaLoader.currentSession : null
            }

            Connections {
                target: loginListShown ? loginAreaLoader.item : null
                onSelected: root.selected(index)
                onResponded: root.responded(response)
                // The initially selected session lags behind the component completion
                // so this provides the initial session name when available
                onLoginListSessionChanged: {
                    if (loginListShown && !loginAreaLoader.sessionUpdated) {
                        loginAreaLoader.currentSession = loginAreaLoader.item.currentSession
                    }
                }
                onPromptlessLogin: root.promptlessLogin()

                onSessionChooserButtonClicked: loginListShown = false;
                ignoreUnknownSignals: true
            }

            Connections {
                target: !loginListShown ? loginAreaLoader.item : null
                onSessionSelected: {
                    loginAreaLoader.loginListShown = true
                    loginAreaLoader.sessionUpdated = true
                    loginAreaLoader.currentSession = sessionName
                }
                ignoreUnknownSignals: true
            }
        }
    }
}
