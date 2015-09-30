/*
 * Copyright (C) 2013,2014 Canonical, Ltd.
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
import Ubuntu.SystemSettings.Diagnostics 1.0
import ".." as LocalComponents

LocalComponents.Page {
    id: reportingPage
    objectName: "reportingPage"

    title: i18n.tr("Improving your experience")
    forwardButtonSourceComponent: forwardButton

    skipValid: false
    skip: !diagnostics.reportCrashes // skip the page when the system is configured not to report crashes

    UbuntuDiagnostics {
        id: diagnostics
        Component.onCompleted: reportingPage.skipValid = true;
    }

    Column {
        id: column
        anchors.fill: content
        spacing: units.gu(2)

        Label {
            anchors.left: parent.left
            anchors.right: parent.right
            wrapMode: Text.Wrap
            text: i18n.tr("Your phone is set up to automatically report errors to Canonical and its partners, the makers of the operating system.")
        }

        Label {
            anchors.left: parent.left
            anchors.right: parent.right
            wrapMode: Text.Wrap
            text: i18n.tr("This can be disabled in <b>System Settings</b> under <b>Security &amp; Privacy</b>")
        }
    }

    Component {
        id: forwardButton
        LocalComponents.StackButton {
            text: i18n.tr("Continue")
            onClicked: pageStack.next()
        }
    }
}
