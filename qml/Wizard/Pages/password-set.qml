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
    forwardButtonSourceComponent: forwardButton
    customTitle: true
    title: confirmPhase ? i18n.tr("Confirm password") : i18n.tr("Choose password")
    backButtonText: i18n.tr("Cancel")

    property alias password: passwordField.text
    readonly property int passwordScore: scorePassword(password)
    property bool confirmPhase: false

    // If we are entering this page, clear any saved password and get focus
    onEnabledChanged: if (enabled) password = ""

    Component.onCompleted: {
        setInfo()
        passwordField.forceActiveFocus()
    }

    function confirm() {
        root.password = password
        confirmTimer.start()
    }

    Timer {
        id: confirmTimer
        interval: UbuntuAnimation.SnapDuration
        onTriggered: {
            confirmPhase = true
            password = ""
            passwordField.forceActiveFocus()
        }
    }

    function setError(text) {
        if (!!text) {
            infoLabel.hasError = true
            infoLabel.text = text
        }
    }

    function setInfo(text) {
        infoLabel.hasError = false
        if (!!text) {
            infoLabel.text = text
        } else {
            infoLabel.text = i18n.tr("Enter at least 4 characters")
        }
    }

    function scorePassword(pass) {
        var score = 0;
        if (!pass)
            return score;

        // award every unique letter until 5 repetitions
        var letters = Object();
        for (var i=0; i<pass.length; i++) {
            letters[pass[i]] = (letters[pass[i]] || 0) + 1;
            score += 5.0 / letters[pass[i]];
        }

        // bonus points for mixing it up
        var variations = {
            digits: /\d/.test(pass),
            lower: /[a-z]/.test(pass),
            upper: /[A-Z]/.test(pass),
            nonWords: /\W/.test(pass),
        }

        var variationCount = 0;
        for (var check in variations) {
            variationCount += (variations[check] === true) ? 1 : 0;
        }
        score += (variationCount - 1) * 10;

        return parseInt(score);
    }

    Item {
        id: column
        anchors.fill: content

        Label {
            id: infoLabel
            property bool hasError: false
            anchors {
                left: parent.left
                right: parent.right
            }
            wrapMode: Text.Wrap
            color: hasError ? "#e14141": "#525252"
        }

        TextField {
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
                    if (password !== root.password) {
                        setError(i18n.tr("Passwords do not match"))
                    } else {
                        setInfo(i18n.tr("Passwords match"))
                    }
                }
            }
        }

        Rectangle {
            id: passwordStrengthMeter
            anchors {
                left: parent.left
                right: parent.right
                top: passwordField.bottom
                topMargin: units.gu(1)
            }
            width: parent.width
            height: units.gu(1)
            color: {
                if (passwordScore > 80)
                    return "green";
                if (passwordScore > 60)
                    return "orange";
                if (passwordScore >= 30)
                    return "red";

                return "red";
            }
            visible: password.length > 0
        }

        Label {
            id: passwordStrengthInfo
            anchors {
                left: parent.left
                right: parent.right
                top: passwordStrengthMeter.bottom
                topMargin: units.gu(1)
            }
            wrapMode: Text.Wrap
            text: {
                if (passwordScore > 80)
                    return i18n.tr("Strong password");
                else if (passwordScore > 60)
                    return i18n.tr("Medium password")
                if (passwordScore >= 30)
                    return i18n.tr("Weak password");

                return i18n.tr("Very weak password");
            }
            color: "#888888"
            fontSize: "small"
            font.weight: Font.Light
            visible: password.length > 0
        }
    }

    Component {
        id: forwardButton
        LocalComponents.StackButton {
            enabled: confirmPhase ? password === root.password : password.length >= 4 // TODO set more sensible restrictions for the length?
            text: i18n.tr("OK")
            onClicked:  {
                if (confirmPhase) {
                    pageStack.next()
                } else {
                    passwdSetPage.confirm()
                }
            }
        }
    }
}
