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
import Lomiri.Components 1.3
import Lomiri.Connectivity 1.0
import Lomiri.SystemSettings.SecurityPrivacy 1.0
import Lomiri.SystemSettings.Update 1.0
import Lomiri.SystemSettings.TimeDate 1.1
import Lomiri.SelfTest 0.1 as UT
import Wizard 0.1
import Lomiri.InputInfo 0.1
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

                Component.onCompleted: {
                    MockInputDeviceBackend.addMockDevice("/test", InputInfo.Keyboard);
                }

                Component.onDestruction: {
                    MockInputDeviceBackend.removeDevice("/test");
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

    SignalSpy {
        id: kbdLayoutSpy
        target: AccountsService
        signalName: "keymapsChanged"
    }

    SignalSpy {
        id: updateDownloadedSpy
        target: SystemImage
        signalName: "updateDownloaded"
    }

    SignalSpy {
        id: applyUpdateSpy
        target: SystemImage
        signalName: "applyUpdate"
    }

    SignalSpy {
        id: skipUntilFinishedSpy
        target: System
        signalName: "wouldHaveSetSkipUntilFinish"
    }

    UT.LomiriTestCase {
        id: wizardTests
        name: "Wizard"
        when: windowShown

        property Item wizard: wizardLoader.status === Loader.Ready ? wizardLoader.item : null

        function init() {
            i18n.language = "en";
            MockQOfono.setModems(["sim1"], [false], []);
            MockQOfono.available = true;
            MockQOfono.ready = true;

            System.wizardEnabled = true;
            System.isUpdate = false;

            SystemImage.updateAvailable = false;
            SystemImage.checkingForUpdates = false;

            NetworkingStatus.status = NetworkingStatus.Offline;

            updateSessionLanguageSpy.clear();
            setSecuritySpy.clear();
            activateLocationSpy.clear();
            activateGPSSpy.clear();
            timezoneSpy.clear();
            kbdLayoutSpy.clear();
            updateDownloadedSpy.clear();
            applyUpdateSpy.clear();
            skipUntilFinishedSpy.clear();

            // reload our test subject to get it in a fresh state once again
            wizardLoader.active = true;

            tryCompare(wizardLoader, "status", Loader.Ready);

            var pages = findChild(wizard, "wizardPages")
            var security = findInvisibleChild(pages, "securityPrivacy");
            security.setSecurity("", "", LomiriSecurityPrivacyPanel.Swipe);
            setSecuritySpy.target = security;

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
        }

        function waitForPage(name) {
            var pages = findChild(wizard, "wizardPages");
            var stack = findChild(pages, "pageStack");
            // don't simply call tryCompare here, because stack.currentPage will be swapped out itself
            tryCompareFunction(function() { return stack.currentPage.objectName; }, name, 15000);
            var contentAnimation = findInvisibleChild(stack.currentPage, "contentAnimation");
            tryCompareFunction(function() { return contentAnimation.running; }, false);
            tryCompare(stack.currentPage, "opacity", 1.0);
            tryCompare(stack.currentPage, "enabled", true);
            tryCompare(stack.currentPage, "skipValid", true);
            tryCompare(stack.currentPage, "skip", false);
            waitForRendering(stack.currentPage);
            return stack.currentPage;
        }

        function goToPage(name, skipSim) {
            if (skipSim === undefined) {
                skipSim = false;
            }

            var page = waitForPage("languagePage");
            if (name === page.objectName) return page;
            tap(findChild(page, "forwardButton"));

            if (!skipSim) {
                page = waitForPage("simPage");
                if (name === page.objectName) return page;
                tap(findChild(page, "forwardButton"));
            }

            page = waitForPage("keyboardPage");
            if (name === page.objectName) return page;
            tap(findChild(page, "forwardButton"));

            page = waitForPage("wifiPage");
            if (name === page.objectName) return page;
            tap(findChild(page, "forwardButton"));

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

            if (name != "passwdPage") {
                // Skip the password prompt
                var pages = findChild(wizard, "wizardPages");
                var security = findInvisibleChild(pages, "securityPrivacy");
                security.setSecurity("", "", LomiriSecurityPrivacyPanel.Passphrase);
                tap(findChild(page, "forwardButton"));
            } else {
                tap(findChild(page, "forwardButton"));
                page = waitForPage("passwdPage");
                if (name === page.objectName) return page;
                tap(findChild(page, "forwardButton"));
            }

            page = waitForPage("systemUpdatePage");
            if (name === page.objectName) return page;
            waitUntilTransitionsEnd(page);
            tap(findChild(page, "forwardButton"));

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
            tap(findChild(page, "languageDelegate_french_(france)")); // should invoke "fr" lang

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
            security.setSecurity("", "", LomiriSecurityPrivacyPanel.Passphrase);
            tryCompare(security, "securityType", LomiriSecurityPrivacyPanel.Passphrase);

            // Make sure that moving from sim page lands on wifi page
            tap(findChild(page, "forwardButton"));
            waitForPage("keyboardPage"); // thus skipping passwdPage
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
            tryVerify(function() { return error.text !== ""; });

            enterPasscode("1111");

            // now finish up
            page = waitForPage("finishedPage");
            waitUntilTransitionsEnd(page);
            tap(findChild(page, "finishButton"));

            setSecuritySpy.wait();
            compare(setSecuritySpy.signalArguments[0][0], "");
            compare(setSecuritySpy.signalArguments[0][1], "1111");
            compare(setSecuritySpy.signalArguments[0][2], LomiriSecurityPrivacyPanel.Passcode);
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
            page = waitForPage("finishedPage");
            waitUntilTransitionsEnd(page);
            tap(findChild(page, "finishButton"));

            setSecuritySpy.wait();
            compare(setSecuritySpy.signalArguments[0][0], "");
            compare(setSecuritySpy.signalArguments[0][1], "12345678");
            compare(setSecuritySpy.signalArguments[0][2], LomiriSecurityPrivacyPanel.Passphrase);
        }

        function test_passwdSwipe() {
            var page = goToPage("passwdPage");
            tap(findChild(page, "passwdDelegate2")); // swipe option

            // now finish up
            tap(findChild(page, "forwardButton"));
            page = waitForPage("finishedPage");
            waitUntilTransitionsEnd(page);
            tap(findChild(page, "finishButton"));

            tryCompare(setSecuritySpy, "count", 0); // not called for swipe method
        }

        function test_timezonePage() {
            var page = goToPage("tzPage");
            verify(page);
            timezoneSpy.target = page.tdModule;

            var tzFilter = findChild(page, "tzFilter");
            verify(tzFilter);
            tap(tzFilter);
            typeString("Belfa");

            var tzList = findChild(page, "tzList");
            verify(tzList);

            // test filtering works and returns some results
            tryCompareFunction(function() { return tzList.count > 0; }, true);

            // just tap the first one
            tap(findChild(page, "tz0"));

            // go next and verify the (mock) signal got fired
            tap(findChild(page, "forwardButton"));
            timezoneSpy.wait();
            compare(timezoneSpy.signalArguments[0][0], "Europe/London");
            compare(timezoneSpy.signalArguments[0][1], "Belfast");
        }

        function test_systemUpdatePage() {

            compare(updateDownloadedSpy.count, 0);
            SystemImage.updateAvailable = true;
            SystemImage.targetBuildNumber = 42;
            SystemImage.updateDownloaded();
            updateDownloadedSpy.wait();

            var page = goToPage("systemUpdatePage");
            var updateButton = findChild(page, "installButton");

            compare(skipUntilFinishedSpy.count, 0);
            compare(applyUpdateSpy.count, 0);
            tap(updateButton);
            skipUntilFinishedSpy.wait();
            applyUpdateSpy.wait();
        }

        function test_accountPage() {
            var page = goToPage("accountPage");
            var forwardButton = findChild(page, "forwardButton");

            tap(findChild(page, "nameInput"));
            typeString("foobar");
        }

        function test_keyboardPage() {
            var page = goToPage("keyboardPage");
            var forwardButton = findChild(page, "forwardButton");

            // change language
            var langSelector = findChild(page, "langSelector");
            verify(langSelector);
            langSelector.selectedIndex = 1; // should be fr_FR

            // pick some layout
            var kbdDelegate = findChild(page, "kbdDelegate1");
            verify(kbdDelegate);
            mouseClick(kbdDelegate);
            verify(kbdDelegate.isCurrent);

            // verify the keymapsChanged signal got fired
            tap(findChild(page, "forwardButton"));
            tryCompare(kbdLayoutSpy, "count", 1);
        }
    }
}
