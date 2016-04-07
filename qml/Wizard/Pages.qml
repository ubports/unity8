/*
 * Copyright (C) 2013-2016 Canonical, Ltd.
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
import MeeGo.QOfono 0.2
import Ubuntu.Components 1.3
import Ubuntu.SystemSettings.SecurityPrivacy 1.0
import Ubuntu.SystemSettings.Diagnostics 1.0
import Wizard 0.1
import "../Components"

StyledItem {
    id: root
    objectName: "wizardPages"
    focus: true

    signal quit()

    // These should be set by a security page and we apply the settings when
    // the user exits the wizard.
    property int passwordMethod: UbuntuSecurityPrivacyPanel.Passphrase
    property string password: ""

    property bool seenSIMPage: false // we want to see the SIM page at most once

    property alias modemManager: modemManager
    property alias simManager0: simManager0
    property alias simManager1: simManager1

    theme: ThemeSettings {
        name: "Ubuntu.Components.Themes.Ambiance"
    }

    UbuntuSecurityPrivacyPanel {
        id: securityPrivacy
        objectName: "securityPrivacy"
    }

    UbuntuDiagnostics {
        id: diagnostics
        objectName: "diagnostics"
    }

    OfonoManager { // need it here for the language and country detection
        id: modemManager
        readonly property bool gotSimCard: available && ((simManager0.ready && simManager0.present) || (simManager1.ready && simManager1.present))
        property bool ready: false
        onModemsChanged: {
            ready = true;
        }
    }

    // Ideally we would query the system more cleverly than hardcoding two
    // sims.  But we don't yet have a more clever way.  :(
    OfonoSimManager {
        id: simManager0
        modemPath: modemManager.modems.length >= 1 ? modemManager.modems[0] : ""
    }

    OfonoSimManager {
        id: simManager1
        modemPath: modemManager.modems.length >= 2 ? modemManager.modems[1] : ""
    }

    function quitWizard() {
        pageStack.currentPage.enabled = false;

        if (password != "") {
            var errorMsg = securityPrivacy.setSecurity("", password, passwordMethod)
            if (errorMsg !== "") {
                // Ignore (but log) any errors, since we're past where the user set
                // the method.  Worst case, we just leave the user with a swipe
                // security method and they fix it in the system settings.
                console.log("Error setting security method:", errorMsg)
            }
        }

        quit();
    }

    MouseArea { // eat anything that gets past widgets
        anchors.fill: parent
    }

    Rectangle {
        id: background
        anchors.fill: root
        color: "#fdfdfd"
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
                pop();
            load(pageList.next());
        }

        function prev() {
            var isPrimaryPage = currentPage && !currentPage.customTitle;
            if (pageList.index >= pageStack.depth - 1) {
                pageList.prev(); // update pageList.index, but not for extra pages
            }
            pop()
            if (!currentPage || currentPage.opacity === 0) { // undo skipped pages
                prev();
            } else {
                currentPage.enabled = true;
            }

            if (isPrimaryPage) {
                currentPage.aboutToShow(UbuntuAnimation.BriskDuration, Qt.LeftToRight);
            } else {
                currentPage.aboutToShowSecondary(UbuntuAnimation.BriskDuration);
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

            var isPrimaryPage = !currentPage.customTitle;
            if (isPrimaryPage) {
                currentPage.aboutToShow(UbuntuAnimation.BriskDuration, Qt.RightToLeft);
            } else {
                currentPage.aboutToShowSecondary(UbuntuAnimation.BriskDuration);
            }
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
                console.warn("Wizard page " + pageStack.currentPage.objectName + " skipped due to taking too long!!!");
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
