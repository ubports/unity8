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
import Ubuntu.SystemSettings.TimeDate 1.0
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

                Component.onDestruction: {
                    wizardLoader.itemDestroyed = true;
                }
            }
        }
    }

    SignalSpy {
        id: updateSessionLanguageSpy
        target: System
        signalName: "updateSessionLocaleCalled"
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

    SignalSpy {
        id: timezoneSpy
        signalName: "timeZoneChangedCalled"
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
        timezoneSpy.clear();

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

            page = waitForPage("wifiPage");
            if (name === page.objectName) return page;
            tap(findChild(page, "forwardButton"));

            if (!skipLocation) {
                page = waitForPage("locationPage");
                if (name === page.objectName) return page;
                tap(findChild(page, "forwardButton"));
            }

            page = waitForPage("tzPage");
            if (name === page.objectName) return page;
            waitUntilTransitionsEnd(page);
            var tzList = findChild(page, "tzList");
            verify(tzList);
            waitForRendering(tzList);
            page.selectedTimeZone = "Pacific/Honolulu";
            tap(findChild(page, "forwardButton"));

            page = waitForPage("accountPage");
            if (name === page.objectName) return page;
            tap(findChild(page, "nameInput"));
            typeString("foobar");
            tap(findChild(page, "forwardButton"));

            page = waitForPage("passwdPage");
            if (name === page.objectName) return page;
            tap(findChild(page, "forwardButton"));

            if (!skipReporting) {
                page = waitForPage("reportingPage");
                if (name === page.objectName) return page;
                tap(findChild(page, "forwardButton"));
            }

            page = waitForPage("finishedPage");
            if (name === page.objectName) return page;
            waitUntilTransitionsEnd(page);
            tap(findChild(page, "finishButton"));

            tryCompare(wizard, "shown", false);
            compare(name, null);
            return null;
        }

        function test_languageChange() {
            var page = goToPage("languagePage");
            tap(findChild(page, "languageDelegate1")); // should invoke "fr" lang

            tryCompare(i18n, "language", "fr_FR");
            tap(findChild(page, "forwardButton"));
            tryCompare(updateSessionLanguageSpy, "count", 1);
            compare(updateSessionLanguageSpy.signalArguments[0][0], "fr_FR");
        }

        function test_languageNoChange() {
            var page = goToPage("languagePage");
            tap(findChild(page, "forwardButton"));
            compare(updateSessionLanguageSpy.count, 0);
        }

        function test_simUnavailableSkip() {
            MockQOfono.available = false;
            goToPage("wifiPage", true);
        }

        function test_simNoModemsSkip() {
            MockQOfono.setModems([], [], []);
            goToPage("wifiPage", true);
        }

        function test_simFirstSkip() {
            MockQOfono.setModems(["a", "b"], [true, false], []);
            goToPage("wifiPage", true);
        }

        function test_simSecondSkip() {
            MockQOfono.setModems(["a", "b"], [false, true], []);
            goToPage("wifiPage", true);
        }

        function test_simBothSkip() {
            MockQOfono.setModems(["a", "b"], [true, true], []);
            goToPage("wifiPage", true);
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

        function verifyAnimationsNotRunning(page) {
            var contentAnimation = findInvisibleChild(page, "contentAnimation");
            var secondaryAnimation = findInvisibleChild(page, "secondaryAnimation");
            tryCompare(contentAnimation, "running", false);
            tryCompare(secondaryAnimation, "running", false);
        }

        function test_passwdPasscode() {
            var page = goToPage("passwdPage");
            tap(findChild(page, "passwdDelegate1")); // passcode option
            tap(findChild(page, "forwardButton"));
            page = waitForPage("passcodeSetPage");
            verifyAnimationsNotRunning(page);

            enterPasscode("1111");
            page = waitForPage("passcodeConfirmPage");
            verifyAnimationsNotRunning(page);

            tap(findChild(page, "backButton"));
            page = waitForPage("passcodeSetPage");
            verifyAnimationsNotRunning(page);

            enterPasscode("1111");
            page = waitForPage("passcodeConfirmPage");
            verifyAnimationsNotRunning(page);

            enterPasscode("1112");
            var error = findChild(page, "wrongNoticeLabel");
            tryCompareFunction(function() { return error.text !== ""; }, true);

            enterPasscode("1111");

            // now finish up
            page = waitForPage("reportingPage");
            tap(findChild(page, "forwardButton"));
            page = waitForPage("finishedPage");
            waitUntilTransitionsEnd(page);
            tap(findChild(page, "finishButton"));

            tryCompare(setSecuritySpy, "count", 1);
            compare(setSecuritySpy.signalArguments[0][0], "");
            compare(setSecuritySpy.signalArguments[0][1], "1111");
            compare(setSecuritySpy.signalArguments[0][2], UbuntuSecurityPrivacyPanel.Passcode);
        }

        function test_passwdPassphrase() {
            var page = goToPage("passwdPage");
            tap(findChild(page, "passwdDelegate0")); // password option
            tap(findChild(page, "forwardButton"));
            page = waitForPage("passwdSetPage");

            var passwdField = findChild(page, "passwordField");
            verify(passwdField);
            tap(passwdField);
            verifyAnimationsNotRunning(page);
            typeString("aaa");
            var continueButton = findChild(page, "forwardButton");
            tryCompare(page, "passwordsMatching", false);

            tap(passwdField);
            verifyAnimationsNotRunning(page);
            passwdField.selectAll(); // overwrite the text
            typeString("12345678");
            tryCompare(page, "passwordsMatching", false);

            var passwd2Field = findChild(page, "password2Field");
            tap(passwd2Field);
            verifyAnimationsNotRunning(page);
            typeString("12345678");
            tryCompare(continueButton, "enabled", true);
            tap(continueButton);

            // now finish up
            page = waitForPage("reportingPage");
            tap(findChild(page, "forwardButton"));
            page = waitForPage("finishedPage");
            waitUntilTransitionsEnd(page);
            tap(findChild(page, "finishButton"));

            tryCompare(setSecuritySpy, "count", 1);
            compare(setSecuritySpy.signalArguments[0][0], "");
            compare(setSecuritySpy.signalArguments[0][1], "12345678");
            compare(setSecuritySpy.signalArguments[0][2], UbuntuSecurityPrivacyPanel.Passphrase);
        }

        function test_passwdSwipe() {
            var page = goToPage("passwdPage");
            tap(findChild(page, "passwdDelegate2")); // swipe option

            // now finish up
            tap(findChild(page, "forwardButton"));
            page = waitForPage("reportingPage");
            tap(findChild(page, "forwardButton"));
            page = waitForPage("finishedPage");
            waitUntilTransitionsEnd(page);
            tap(findChild(page, "finishButton"));

            tryCompare(setSecuritySpy, "count", 0); // not called for swipe method
        }

        function test_locationGpsOnly() {
            var page = goToPage("locationPage");
            var gpsCheck = findChild(page, "gpsCheckLabel");
            var hereCheck = findChild(page, "hereCheckLabel");
            var nopeCheck = findChild(page, "nopeCheckLabel");

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
            var gpsCheck = findChild(page, "gpsCheckLabel");
            var hereCheck = findChild(page, "hereCheckLabel");
            var nopeCheck = findChild(page, "nopeCheckLabel");

            var locationActionGroup = findInvisibleChild(page, "locationActionGroup");
            activateLocationSpy.target = locationActionGroup.location;
            activateGPSSpy.target = locationActionGroup.gps;

            tap(nopeCheck);
            tryCompare(gpsCheck, "checked", false);
            tryCompare(hereCheck, "checked", false);
            tryCompare(nopeCheck, "checked", true);

            tap(findChild(page, "forwardButton"));
            tryCompare(AccountsService, "hereEnabled", false);
            tryCompare(activateLocationSpy, "count", 0);
            tryCompare(activateGPSSpy, "count", 0);
        }

        function test_locationHere() {
            var page = goToPage("locationPage");
            var gpsCheck = findChild(page, "gpsCheckLabel");
            var hereCheck = findChild(page, "hereCheckLabel");
            var nopeCheck = findChild(page, "nopeCheckLabel");

            var locationActionGroup = findInvisibleChild(page, "locationActionGroup");
            activateLocationSpy.target = locationActionGroup.location;
            activateGPSSpy.target = locationActionGroup.gps;

            // no tap because HERE is the default
            tryCompare(gpsCheck, "checked", false);
            tryCompare(hereCheck, "checked", true);
            tryCompare(nopeCheck, "checked", false);

            tap(findChild(page, "forwardButton"));
            tryCompare(AccountsService, "hereEnabled", true);
            tryCompare(activateLocationSpy, "count", 1);
            tryCompare(activateGPSSpy, "count", 1);
        }

        function test_timezonePage() {
            var page = goToPage("tzPage");
            verify(page);
            timezoneSpy.target = page.tdModule;

            var tzFilter = findChild(page, "tzFilter");
            verify(tzFilter);
            tap(tzFilter);
            typeString("London");

            var tzList = findChild(page, "tzList");
            verify(tzList);

            // test filtering works and returns some results
            tryCompareFunction(function() { return tzList.count > 0; }, true);

            // just tap the first one
            tap(findChild(page, "tz0"));

            // go next and verify the (mock) signal got fired
            tap(findChild(page, "forwardButton"));
            tryCompare(timezoneSpy, "count", 1);
            tryCompare(page.tdModule, "timeZone", timezoneSpy.signalArguments[0][0]);
        }

        function test_accountPage() {
            var page = goToPage("accountPage");
            var forwardButton = findChild(page, "forwardButton");

            tap(findChild(page, "nameInput"));
            typeString("foobar");
        }
    }
}
