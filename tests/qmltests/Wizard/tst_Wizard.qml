/*
 * Copyright 2014,2015 Canonical Ltd.
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
import QtTest 1.0
import AccountsService 0.1
import MeeGo.QOfono 0.2
import QMenuModel 0.1
import Ubuntu.Components 1.3
import Ubuntu.SystemSettings.SecurityPrivacy 1.0
import Unity.Test 0.1 as UT
import Wizard 0.1
import "../../../qml/Wizard"

Item {
    id: root
    width: units.gu(40)
    height: units.gu(71)

    Loader {
        id: wizardLoader
        anchors.fill: parent

        property bool itemDestroyed: false
        sourceComponent: Component {
            Wizard {
                id: wizard
                anchors.fill: parent
                background: Qt.resolvedUrl("../../../qml/graphics/phone_background.jpg")

                Component.onDestruction: {
                    wizardLoader.itemDestroyed = true;
                }
            }
        }
    }

    SignalSpy {
        id: updateSessionLanguageSpy
        target: System
        signalName: "updateSessionLanguageCalled"
    }

    SignalSpy {
        id: setSecuritySpy
        signalName: "setSecurityCalled"
    }

    SignalSpy {
        id: activateLocationSpy
        signalName: "activated"
    }

    SignalSpy {
        id: activateGPSSpy
        signalName: "activated"
    }

    function setup() {
        AccountsService.hereEnabled = false;
        AccountsService.hereLicensePath = Qt.resolvedUrl("licenses");
        i18n.language = "en";
        MockQOfono.setModems(["sim1"], [false], []);
        MockQOfono.available = true;
        MockQOfono.ready = true;
        System.wizardEnabled = true;

        updateSessionLanguageSpy.clear();
        setSecuritySpy.clear();
        activateLocationSpy.clear();
        activateGPSSpy.clear();

        ActionData.data = {
            "location-detection-enabled": {
                'valid': true,
                'state': false
            },
            "gps-detection-enabled": {
                'valid': true,
                'state': false
            }
        };
    }

    Component.onCompleted: {
        theme.name = "Ubuntu.Components.Themes.SuruGradient";
        setup();
    }

    UT.UnityTestCase {
        id: wizardTests
        name: "Wizard"
        when: windowShown

        property Item wizard: wizardLoader.status === Loader.Ready ? wizardLoader.item : null

        function cleanup() {
            wizardLoader.itemDestroyed = false;

            wizardLoader.active = false;

            tryCompare(wizardLoader, "status", Loader.Null);
            tryCompare(wizardLoader, "item", null);
            // Loader.status might be Loader.Null and Loader.item might be null but the Loader
            // item might still be alive. So if we set Loader.active back to true
            // again right now we will get the very same Shell instance back. So no reload
            // actually took place. Likely because Loader waits until the next event loop
            // iteration to do its work. So to ensure the reload, we will wait until the
            // Shell instance gets destroyed.
            tryCompare(wizardLoader, "itemDestroyed", true);

            // reload our test subject to get it in a fresh state once again
            wizardLoader.active = true;

            tryCompare(wizardLoader, "status", Loader.Ready);

            var pages = findChild(wizard, "wizardPages");
            var security = findInvisibleChild(pages, "securityPrivacy");
            security.setSecurity("", "", UbuntuSecurityPrivacyPanel.Swipe);
            setSecuritySpy.target = security;

            setup();
        }

        function waitForPage(name) {
            var pages = findChild(wizard, "wizardPages");
            var stack = findChild(pages, "pageStack");
            // don't simply call tryCompare here, because stack.currentPage will be swapped out itself
            tryCompareFunction(function() { return stack.currentPage.objectName; }, name);
            tryCompare(stack.currentPage, "opacity", 1.0);
            tryCompare(stack.currentPage, "enabled", true);
            tryCompare(stack.currentPage, "skipValid", true);
            tryCompare(stack.currentPage, "skip", false);
            waitForRendering(stack.currentPage);
            return stack.currentPage;
        }

        function verifyPageIsBlocked(name) {
            var pages = findChild(wizard, "wizardPages");
            var stack = findChild(pages, "pageStack");
            // don't simply call tryCompare here, because stack.currentPage will be swapped out itself
            tryCompareFunction(function() { return stack.currentPage.objectName; }, name);
            tryCompare(stack.currentPage, "enabled", false);
            tryCompare(stack.currentPage, "skipValid", false);
            waitForRendering(stack.currentPage);
            return stack.currentPage;
        }

        function goToPage(name, skipSim, skipLocation, skipReporting) {
            if (skipSim === undefined) {
                skipSim = false;
            }
            if (skipLocation === undefined) {
                skipLocation = false;
            }
            if (skipReporting === undefined) {
                skipReporting = false;
            }

            var page = waitForPage("languagePage");
            if (name === page.objectName) return page;
            tap(findChild(page, "forwardButton"));

            if (!skipSim) {
                page = waitForPage("simPage");
                if (name === page.objectName) return page;
                tap(findChild(page, "forwardButton"));
            }

            page = waitForPage("passwdPage");
            if (name === page.objectName) return page;
            tap(findChild(page, "passwdDelegate0"));
            tap(findChild(page, "forwardButton"));

            page = waitForPage("wifiPage");
            if (name === page.objectName) return page;
            tap(findChild(page, "forwardButton"));

            if (!skipLocation) {
                page = waitForPage("locationPage");
                if (name === page.objectName) return page;
                tap(findChild(page, "forwardButton"));
            }

            if (!skipReporting) {
                page = waitForPage("reportingPage");
                if (name === page.objectName) return page;
                tap(findChild(page, "forwardButton"));
            }

            page = waitForPage("finishedPage");
            if (name === page.objectName) return page;
            tap(findChild(page, "forwardButton"));

            tryCompare(wizard, "shown", false);
            compare(name, null);
            return null;
        }

        function test_languageChange() {
            var page = goToPage("languagePage");
            tap(findChild(page, "languageCombo"));
            waitForRendering(findChild(page, "languageDelegate1"));

            // For some reason, the delegate *sometimes* (like 1 in 10 maybe)
            // needs more time before it can process a tap() call.  I can't
            // find a rhyme or reason, its properties all seem the same in
            // cases where it works and does not.  This failure to receive a
            // tap() call below does *not* happen when running in xvfb, so
            // jenkins is unaffected (and we don't have to worry about 100 not
            // being enough time in its slow environment).  This wait() call is
            // just to help local runs not trip up.
            wait(100);
            tap(findChild(page, "languageDelegate1"));

            tryCompare(i18n, "language", "fr");
            tap(findChild(page, "forwardButton"));
            tryCompare(updateSessionLanguageSpy, "count", 1);
            compare(updateSessionLanguageSpy.signalArguments[0][0], "fr");
        }

        function test_languageNoChange() {
            goToPage("simPage"); // one past language page
            compare(updateSessionLanguageSpy.count, 0);
        }

        function test_simUnavailableSkip() {
            MockQOfono.available = false;
            goToPage("passwdPage", true);
        }

        function test_simNoModemsSkip() {
            MockQOfono.setModems([], [], []);
            goToPage("passwdPage", true);
        }

        function test_simFirstSkip() {
            MockQOfono.setModems(["a", "b"], [true, false], []);
            goToPage("passwdPage", true);
        }

        function test_simSecondSkip() {
            MockQOfono.setModems(["a", "b"], [false, true], []);
            goToPage("passwdPage", true);
        }

        function test_simBothSkip() {
            MockQOfono.setModems(["a", "b"], [true, true], []);
            goToPage("passwdPage", true);
        }

        function test_simWaitOnManagerAsync() {
            MockQOfono.ready = false;
            MockQOfono.setModems(["a"], [false], []);

            // Go to SIM page, which will be waiting for skip to be valid
            var page = goToPage("languagePage");
            tap(findChild(page, "forwardButton"));
            verifyPageIsBlocked("simPage");

            // Now release QOfono from blocking the page
            MockQOfono.ready = true;

            waitForPage("simPage");
        }

        function test_simWaitOnCardAsync() {
            MockQOfono.setModems(["a"], [false], [false]);

            // Go to SIM page, which will be waiting for skip to be valid
            var page = goToPage("languagePage");
            tap(findChild(page, "forwardButton"));
            verifyPageIsBlocked("simPage");

            // Now release QOfono from blocking the page
            MockQOfono.setModems(["a"], [false], [true]);

            waitForPage("simPage");
        }

        function test_simWaitTimeout() {
            MockQOfono.setModems(["a"], [false], [false]);

            // Go to SIM page, which will be waiting for skip to be valid
            var page = goToPage("languagePage");
            tap(findChild(page, "forwardButton"));
            verifyPageIsBlocked("simPage");

            var timeout = findInvisibleChild(wizard, "timeout");
            timeout.interval = 100; // reduce our delay

            // Now just wait for timeout
            compare(timeout.running, true);
            waitForPage("passwdPage");
            compare(timeout.running, false);
        }

        function enterPasscode(passcode) {
            for (var i = 0; i < passcode.length; ++i) {
                var character = passcode.charAt(i);
                var button = findChild(wizard, "pinPadButton" + character);
                tap(button);
            }
        }

        function test_passwdSkipIfSet() {
            var page = goToPage("simPage");

            // Set password type to non-swipe
            var pages = findChild(wizard, "wizardPages");
            var security = findInvisibleChild(pages, "securityPrivacy");
            security.setSecurity("", "", UbuntuSecurityPrivacyPanel.Passphrase);
            compare(security.securityType, UbuntuSecurityPrivacyPanel.Passphrase);

            // Make sure that moving from sim page lands on wifi page
            tap(findChild(page, "forwardButton"));
            waitForPage("wifiPage"); // thus skipping passwdPage
        }

        function test_passwdPasscode() {
            var page = goToPage("passwdPage");

            tap(findChild(page, "forwardButton"));
            page = waitForPage("passwdSetPage");

            enterPasscode("1111");
            page = waitForPage("passwdConfirmPage");

            // make sure we go back to 'set' page not 'type' page
            tap(findChild(page, "backButton"));
            page = waitForPage("passwdSetPage");

            enterPasscode("1111");
            page = waitForPage("passwdConfirmPage");

            enterPasscode("1112");
            var error = findChild(page, "wrongNoticeLabel");
            tryCompareFunction(function() { return error.text !== ""; }, true);

            enterPasscode("1111");
            page = waitForPage("wifiPage");

            // now finish up
            tap(findChild(page, "forwardButton"));
            page = waitForPage("locationPage");
            tap(findChild(page, "forwardButton"));
            page = waitForPage("finishedPage");
            tap(findChild(page, "forwardButton"));

            tryCompare(setSecuritySpy, "count", 1);
            compare(setSecuritySpy.signalArguments[0][0], "");
            compare(setSecuritySpy.signalArguments[0][1], "1111");
            compare(setSecuritySpy.signalArguments[0][2], UbuntuSecurityPrivacyPanel.Passcode);
        }

        function test_passwdPassphrase() {
            var page = goToPage("passwdPage");
            tap(findChild(page, "passwdDelegate2"));

            tap(findChild(page, "forwardButton"));
            page = waitForPage("passwdSetPage");

            typeString("aaa");
            var continueButton = findChild(page, "forwardButton");
            tryCompare(continueButton.item, "enabled", false);
            keyClick(Qt.Key_Enter);
            var error = findChild(page, "wrongNoticeLabel");
            tryCompareFunction(function() { return error.text !== ""; }, true);

            typeString("aaaa");
            tap(continueButton);
            page = waitForPage("passwdConfirmPage");

            // make sure we go back to 'set' page not 'type' page
            var back = findChild(page, "backButton");
            tap(back);
            page = waitForPage("passwdSetPage");

            typeString("aaaa");
            keyClick(Qt.Key_Enter);
            page = waitForPage("passwdConfirmPage");

            continueButton = findChild(page, "forwardButton");
            typeString("aaab");
            tryCompare(continueButton.item, "enabled", false);
            keyClick(Qt.Key_Enter);
            var error = findChild(page, "wrongNoticeLabel");
            tryCompareFunction(function() { return error.text !== ""; }, true);

            typeString("aaaa");
            tap(continueButton);
            page = waitForPage("wifiPage");

            // now finish up
            tap(findChild(page, "forwardButton"));
            page = waitForPage("locationPage");
            tap(findChild(page, "forwardButton"));
            page = waitForPage("finishedPage");
            tap(findChild(page, "forwardButton"));

            tryCompare(setSecuritySpy, "count", 1);
            compare(setSecuritySpy.signalArguments[0][0], "");
            compare(setSecuritySpy.signalArguments[0][1], "aaaa");
            compare(setSecuritySpy.signalArguments[0][2], UbuntuSecurityPrivacyPanel.Passphrase);
        }

        function test_passwdSwipe() {
            goToPage(null, false, false, true);

            tryCompare(setSecuritySpy, "count", 1);
            compare(setSecuritySpy.signalArguments[0][0], "");
            compare(setSecuritySpy.signalArguments[0][1], "");
            compare(setSecuritySpy.signalArguments[0][2], UbuntuSecurityPrivacyPanel.Swipe);
        }

        function test_locationSkipNoPath() {
            AccountsService.hereLicensePath = "";
            goToPage("finishedPage", false, true, true);
        }

        function test_locationSkipNoFiles() {
            AccountsService.hereLicensePath = Qt.resolvedUrl("nolicenses");
            goToPage("finishedPage", false, true, true);
        }

        function test_locationWaitOnPath() {
            AccountsService.hereLicensePath = " "; // means we're still getting the path from dbus

            var page = goToPage("wifiPage");

            var pages = findChild(wizard, "wizardPages");
            var stack = findChild(pages, "pageStack");
            tap(findChild(page, "forwardButton"));
            // don't simply call tryCompare here, because stack.currentPage will be swapped out itself
            tryCompareFunction(function() { return stack.currentPage.objectName; }, "locationPage");
            compare(stack.currentPage.enabled, false);
            compare(stack.currentPage.skipValid, false);

            AccountsService.hereLicensePath = "";
            waitForPage("finishedPage", false, false, true);
        }

        function test_locationGpsOnly() {
            var page = goToPage("locationPage");
            var gpsCheck = findChild(page, "gpsCheck");
            var hereCheck = findChild(page, "hereCheck");
            var nopeCheck = findChild(page, "nopeCheck");

            var locationActionGroup = findInvisibleChild(page, "locationActionGroup");
            activateLocationSpy.target = locationActionGroup.location;
            activateGPSSpy.target = locationActionGroup.gps;

            tap(gpsCheck);
            tryCompare(gpsCheck, "checked", true);
            tryCompare(hereCheck, "checked", false);
            tryCompare(nopeCheck, "checked", false);

            tap(findChild(page, "forwardButton"));
            tryCompare(AccountsService, "hereEnabled", false);
            tryCompare(activateLocationSpy, "count", 1)
            tryCompare(activateGPSSpy, "count", 1)
        }

        function test_locationNope() {
            var page = goToPage("locationPage");
            var gpsCheck = findChild(page, "gpsCheck");
            var hereCheck = findChild(page, "hereCheck");
            var nopeCheck = findChild(page, "nopeCheck");

            var locationActionGroup = findInvisibleChild(page, "locationActionGroup");
            activateLocationSpy.target = locationActionGroup.location;
            activateGPSSpy.target = locationActionGroup.gps;

            tap(nopeCheck);
            tryCompare(gpsCheck, "checked", false);
            tryCompare(hereCheck, "checked", false);
            tryCompare(nopeCheck, "checked", true);

            tap(findChild(page, "forwardButton"));
            tryCompare(AccountsService, "hereEnabled", false);
            tryCompare(activateLocationSpy, "count", 0)
            tryCompare(activateGPSSpy, "count", 0)
        }

        function test_locationHere() {
            var page = goToPage("locationPage");
            var gpsCheck = findChild(page, "gpsCheck");
            var hereCheck = findChild(page, "hereCheck");
            var nopeCheck = findChild(page, "nopeCheck");

            var locationActionGroup = findInvisibleChild(page, "locationActionGroup");
            activateLocationSpy.target = locationActionGroup.location;
            activateGPSSpy.target = locationActionGroup.gps;

            // no tap because HERE is the default
            tryCompare(gpsCheck, "checked", false);
            tryCompare(hereCheck, "checked", true);
            tryCompare(nopeCheck, "checked", false);

            tap(findChild(page, "forwardButton"));
            tryCompare(AccountsService, "hereEnabled", true);
            tryCompare(activateLocationSpy, "count", 1)
            tryCompare(activateGPSSpy, "count", 1)
        }

        function test_locationHereTerms() {
            var page = goToPage("locationPage");

            var link = findChild(page, "hereTermsLink");

            // Test our language lookup code a bit

            i18n.language = "fr_FR.UTF-8";
            link.linkActivated("not-used");
            page = waitForPage("hereTermsPage");
            tryCompare(findChild(page, "termsLabel"), "text", "fr_FR\n");
            tap(findChild(page, "backButton"));
            waitForPage("locationPage");

            i18n.language = "fr_CA";
            link.linkActivated("not-used");
            page = waitForPage("hereTermsPage");
            tryCompare(findChild(page, "termsLabel"), "text", "fr_CA\n");
            tap(findChild(page, "backButton"));
            waitForPage("locationPage");

            i18n.language = "fr_US";
            link.linkActivated("not-used");
            page = waitForPage("hereTermsPage");
            tryCompare(findChild(page, "termsLabel"), "text", "fr_FR\n");
            tap(findChild(page, "backButton"));
            waitForPage("locationPage");

            i18n.language = "fr.utf8";
            link.linkActivated("not-used");
            page = waitForPage("hereTermsPage");
            tryCompare(findChild(page, "termsLabel"), "text", "fr_FR\n");
            tap(findChild(page, "backButton"));
            waitForPage("locationPage");

            i18n.language = "es"; // will not be found
            link.linkActivated("not-used");
            page = waitForPage("hereTermsPage");
            tryCompare(findChild(page, "termsLabel"), "text", "en_US\n");

            // OK, done with languages, back to actual page

            var label = findChild(page, "termsLabel");
            label.linkActivated(Qt.resolvedUrl("licenses/en_US.html"));
            tryCompare(label, "visible", false);

            var webview = findChild(page, "webview");
            tryCompare(webview, "visible", true);
            tryCompare(webview, "url", Qt.resolvedUrl("licenses/en_US.html"));
            tryCompare(webview, "loadProgress", 100);

            tap(findChild(page, "backButton"));
            waitForPage("hereTermsPage"); // confirm we're on same page
            tryCompare(webview, "visible", false);
            tryCompare(label, "visible", true);

            tap(findChild(page, "backButton"));
            waitForPage("locationPage");
        }
    }
}
