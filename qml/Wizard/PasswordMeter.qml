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

Item {
    property string password: ""
    readonly property int passwordScore: scorePassword(password)
    property var matching

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

    Rectangle {
        id: passwordStrengthMeter
        anchors {
            left: parent.left
            right: parent.right
        }
        width: parent.width
        height: units.gu(0.5)
        color: {
            if (passwordScore > 80)
                return okColor;
            else if (passwordScore > 60)
                return "#f9c00f";
            else if (passwordScore >= 30)
                return errorColor;

            return errorColor;
        }
        visible: password.length > 0
    }

    Label {
        id: passwordStrengthInfo
        anchors {
            left: parent.left
            right: parent.right
            top: passwordStrengthMeter.bottom
            topMargin: units.gu(.5)
        }
        wrapMode: Text.Wrap
        text: {
            if (matching !== undefined) {
                if (password.length < 8)
                    return i18n.tr("Password too short");
                else if (matching)
                    return i18n.tr("Passwords match");
                else if (!matching)
                    return i18n.tr("Passwords do not match");
            }

            if (passwordScore > 80)
                return i18n.tr("Strong password");
            else if (passwordScore > 60)
                return i18n.tr("Fair password");
            else if (passwordScore >= 30)
                return i18n.tr("Weak password");

            return i18n.tr("Very weak password");
        }
        color: UbuntuColors.ash
        fontSize: "small"
        font.weight: Font.Light
        visible: password.length > 0
    }
}
