/*
 * Copyright (C) 2013,2014,2015 Canonical, Ltd.
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
import Ubuntu.SystemSettings.SecurityPrivacy 1.0
import Wizard 0.1
import "../Components"

Item {
    id: root
    objectName: "wizardPages"
    focus: true

    // The background wallpaper to use
    property string background

    signal quit()

    // These should be set by a security page and we apply the settings when
    // the user exits the wizard.
    property int passwordMethod: UbuntuSecurityPrivacyPanel.Passcode
    property string password: ""

    UbuntuSecurityPrivacyPanel {
        id: securityPrivacy
        objectName: "securityPrivacy"
    }

    function quitWizard() {
        pageStack.currentPage.enabled = false;

        var errorMsg = securityPrivacy.setSecurity("", password, passwordMethod)
        if (errorMsg !== "") {
            // Ignore (but log) any errors, since we're past where the user set
            // the method.  Worst case, we just leave the user with a swipe
            // security method and they fix it in the system settings.
            console.log("Error setting security method:", errorMsg)
        }

        quit();
    }

    MouseArea { // eat anything that gets past widgets
        anchors.fill: parent
    }

    Image {
        id: image
        // Use x/y/height/width instead of anchors so that we don't adjust
        // the image when the OSK appears.
        x: 0
        y: 0
        height: root.height
        width: root.width
        sourceSize.height: height
        sourceSize.width: width
        source: root.background
        fillMode: Image.PreserveAspectCrop
        visible: status === Image.Ready
    }

    PageList {
        id: pageList
    }

    PageStack {
        id: pageStack
        objectName: "pageStack"
        anchors.fill: parent

        function next() {
            // If we've opened any extra (non-main) pages, pop them before
            // continuing so back button returns to the previous main page.
            while (pageList.index < pageStack.depth - 1)
                pop()
            load(pageList.next())
        }

        function prev() {
            if (pageList.index >= pageStack.depth - 1)
                pageList.prev() // update pageList.index, but not for extra pages
            pop()
            if (!currentPage || currentPage.opacity === 0) { // undo skipped pages
                prev()
            } else {
                currentPage.enabled = true
            }
        }

        function load(path) {
            if (currentPage) {
                currentPage.enabled = false
            }

            // First load it invisible, check that we should actually use
            // this page, and either skip it or continue.
            push(path, {"opacity": 0, "enabled": false})

            timeout.restart();

            // Check for immediate skip or not.  We may have to wait for
            // skipValid to be assigned (see Connections object below)
            checkSkip()
        }

        function checkSkip() {
            if (!currentPage) { // may have had a parse error
                next()
            } else if (currentPage.skipValid) {
                if (currentPage.skip) {
                    next()
                } else {
                    currentPage.opacity = 1
                    currentPage.enabled = true
                    timeout.stop();
                }
            }
        }

        Timer {
            id: timeout
            objectName: "timeout"
            interval: 2000 // wizard pages shouldn't take long
            onTriggered: {
                pageStack.currentPage.skip = true;
                pageStack.currentPage.skipValid = true;
            }
        }

        Connections {
            target: pageStack.currentPage
            onSkipValidChanged: pageStack.checkSkip()
        }

        Component.onCompleted: next()
    }
}
