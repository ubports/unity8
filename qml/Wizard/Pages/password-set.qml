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

import QtQuick 2.3
import Ubuntu.Components 1.2
import ".." as LocalComponents
import "../../Components" as UnityComponents

/**
 * See the main passwd-type page for an explanation of why we don't actually
 * directly set the password here.
 */

LocalComponents.Page {
    id: passwdSetPage
    objectName: "passwdSetPage"
    customTitle: true
    buttonBarVisible: false
    title: confirmPhase ? i18n.tr("Confirm Password") : i18n.tr("Choose Password")

    property alias password: passwordField.text
    property bool confirmPhase: false

    // If we are entering this page, clear any saved password and get focus
    onEnabledChanged: if (enabled) password = ""

    Component.onCompleted: {
        setInfo();
        passwordField.forceActiveFocus();
    }

    function confirm() {
        root.password = password;
        confirmTimer.start();
    }

    Timer {
        id: confirmTimer
        interval: UbuntuAnimation.SnapDuration
        onTriggered: {
            confirmPhase = true;
            password = "";
            passwordField.forceActiveFocus();
        }
    }

    function setError(text) {
        if (!!text) {
            infoLabel.hasError = true;
            infoLabel.text = text;
        }
    }

    function setInfo(text) {
        infoLabel.hasError = false;
        if (!!text) {
            infoLabel.text = text;
        } else {
            infoLabel.text = i18n.tr("Enter at least 6 characters");
        }
    }

    Item {
        id: column
        anchors.fill: content
        anchors.leftMargin: leftMargin
        anchors.rightMargin: rightMargin

        Label {
            id: infoLabel
            property bool hasError: false
            anchors {
                left: parent.left
                right: parent.right
                topMargin: units.gu(3)
            }
            wrapMode: Text.Wrap
            color: hasError ? errorColor : textColor
        }

        LocalComponents.WizardTextField {
            id: passwordField
            anchors {
                left: parent.left
                right: parent.right
                top: infoLabel.bottom
                topMargin: units.gu(1)
            }
            echoMode: TextInput.Password
            onTextChanged: {
                if (confirmPhase) {
                    if (password.length == 0) {
                        setInfo();
                    } else if (password !== root.password) {
                        setError(i18n.tr("Passwords do not match"));
                    } else {
                        setInfo(i18n.tr("Passwords match"));
                    }
                }
            }
        }

        // password meter
        LocalComponents.PasswordMeter {
            id: passMeter
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.top: passwordField.bottom
            anchors.topMargin: units.gu(1)
            password: passwordField.text
            visible: !confirmPhase
        }

        // buttons
        Button {
            id: cancelButton
            anchors {
                top: passMeter.bottom
                left: parent.left
                right: parent.horizontalCenter
                rightMargin: units.gu(1)
                topMargin: units.gu(4)
            }
            text: i18n.tr("Cancel")
            onClicked: {
                if (confirmPhase) {
                    confirmPhase = false;
                    password = "";
                    setInfo();
                    passwordField.forceActiveFocus();
                } else {
                    pageStack.prev();
                }
            }
        }

        Button {
            id: okButton
            anchors {
                top: passMeter.bottom
                left: parent.horizontalCenter
                right: parent.right
                leftMargin: units.gu(1)
                topMargin: units.gu(4)
            }
            text: i18n.tr("OK")
            color: okColor
            enabled: confirmPhase ? password === root.password : password.length > 5 // TODO set more sensible restrictions for the length?
            onClicked: {
                if (confirmPhase) {
                    pageStack.next();
                } else {
                    passwdSetPage.confirm();
                }
            }
        }
    }
}
