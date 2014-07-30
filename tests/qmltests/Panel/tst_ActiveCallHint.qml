/*
 * Copyright 2014 Canonical Ltd.
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
import QtTest 1.0
import Unity.Test 0.1 as UT
import Ubuntu.Telephony 0.1 as Telephony
import Unity.Application 0.1
import ".."
import "../../../qml/Panel"

Item {
    width: units.gu(40)
    height: units.gu(20)

    Telephony.CallEntry {
        id: call1
        phoneNumber: "+447812221111"
    }

    Telephony.CallEntry {
        id: call2
        phoneNumber: "+447812221112"
    }

    Telephony.CallEntry {
        id: call3
        phoneNumber: "+447812221113"
    }

    ActiveCallHint {
        id: callHint
        anchors {
            top: parent.top
            left:parent.left
            right:parent.right
        }
        height: units.gu(3)
        labelSwitchInterval: 2000
    }

    Component.onCompleted: {
        contactWactherData.contactData = {
            "+447812221113": {
                "alias": "Bob's Uncle"
            }
        };
        callManager.foregroundCall = call3;
    }

    UT.UnityTestCase {
        name: "ActiveCallHint"
        when: windowShown

        function init() {
            callManager.foregroundCall = null;
            callManager.backgroundCall = null;
            callHint.labelSwitchInterval = 300;

            ApplicationManager.stopApplication("dialer-app");
        }

        function test_activeHint_data() {
            return [
                { tag: "noCall-callNotVisible",  dialer: false, call: null,  visible: false, expected: false },
                { tag: "noCall-callVisible",     dialer: false, call: null,  visible: true,  expected: false },
                { tag: "hasCall-callNotVisible", dialer: false, call: call1, visible: false, expected: true },
                { tag: "hasCall-callVisible",    dialer: false, call: call1, visible: true,  expected: true },

                { tag: "dialerNotFocused-noCall-callNotVisible",  dialer: true, focused: false, call: null,  visible: false, expected: false },
                { tag: "dialerNotFocused-noCall-callVisible",     dialer: true, focused: false, call: null,  visible: true,  expected: false },
                { tag: "dialerNotFocused-hasCall-callNotVisible", dialer: true, focused: false, call: call1, visible: false, expected: true },
                { tag: "dialerNotFocused-hasCall-callVisible",    dialer: true, focused: false, call: call1, visible: true,  expected: true },

                { tag: "dialerFocused-noCall-callNotVisible",  dialer: true, focused: true, call: null,  visible: false, expected: false },
                { tag: "dialerFocused-noCall-callVisible",     dialer: true, focused: true, call: null,  visible: true,  expected: true },
                { tag: "dialerFocused-hasCall-callNotVisible", dialer: true, focused: true, call: call1, visible: false, expected: false },
                { tag: "dialerFocused-hasCall-callVisible",    dialer: true, focused: true, call: call1, visible: true,  expected: true },
            ];
        }

        function test_activeHint(data) {
            if (data.dialer) {
                var application = ApplicationManager.startApplication("dialer-app");
                ApplicationManager.focusApplication("dialer-app");
                tryCompare(ApplicationManager, "focusedApplicationId", "dialer-app");
                tryCompare(application, "state", ApplicationInfo.Running);

                if (!data.focused) { ApplicationManager.unfocusCurrentApplication(); }
            }
            callManager.foregroundCall = data.call;
            callManager.callIndicatorVisible = data.visible;

            compare(callHint.active, data.expected, "Call hint should be active when callIndicatorVisible=true");
        }

        function test_currentCall_data() {
            return [
                { tag: "empty", foreground: null, background: null, active: false, label: "" },
                { tag: "foreground", foreground: call1, background: null, active: true, label: "+447812221111" },
                { tag: "background", foreground: null, background: call2, active: true, label: "+447812221112" },
                { tag: "multiple", foreground: call1, background: call2, active: true, label: "+447812221111" },
            ];
        }

        function test_currentCall(data) {
            callManager.foregroundCall = data.foreground;
            callManager.backgroundCall = data.background;

            var contactLabel = findChild(callHint, "contactLabel");
            verify(contactLabel !== null);

            compare(contactLabel.text, data.label, "Contact label does not match call");
        }

        function test_changeContactData() {
            callManager.backgroundCall = call3;

            var contactLabel = findChild(callHint, "contactLabel");
            verify(contactLabel !== null);

            contactWactherData.contactData = { "+447812221113": { "alias": "Bob's Uncle" } };
            compare(contactLabel.text, "Bob's Uncle", "Contact label does not match call");

            contactWactherData.contactData = { "+447812221113": { "alias": "Freddy" } };
            compare(contactLabel.text, "Freddy", "Contact label does not match call");
        }

        function test_timeLapse() {
            callManager.backgroundCall = call3;

            var timeLabel = findChild(callHint, "timeLabel");
            verify(timeLabel !== null);

            var currentLabel = timeLabel.text;
            tryCompareFunction(function() { return timeLabel.text !== currentLabel }, true);
            currentLabel = timeLabel.text;
            tryCompareFunction(function() { return timeLabel.text !== currentLabel }, true);
        }

        function test_displayedLabelChangesOverTime() {
            callManager.backgroundCall = call3;

            var labelPathView = findChild(callHint, "labelPathView");
            verify(labelPathView !== null);

            var currentOffset = labelPathView.offset
            tryCompareFunction(function() { return labelPathView.offset !== currentOffset }, true);
            currentOffset = labelPathView.offset
            tryCompareFunction(function() { return labelPathView.offset !== currentOffset }, true);
        }
    }
}
