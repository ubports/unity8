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

import QtQuick 2.4
import QtTest 1.0
import Unity.Test 0.1 as UT
import Ubuntu.Telephony 0.1 as Telephony
import Unity.Application 0.1
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
        elapsedTimerRunning: true
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
            call1.elapsedTime = 0;

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
                tryCompare(application.surfaceList, "count", 1);
                MirFocusController.focusedSurface = application.surfaceList.get(0);
                tryCompare(ApplicationManager, "focusedApplicationId", "dialer-app");
                tryCompare(application, "state", ApplicationInfoInterface.Running);

                if (!data.focused) { MirFocusController.focusedSurface = null; }
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

        function test_timeElapsed_data() {
            return [
                { tag: "0:00->0:01", elpasedTime: 0, initial: "0:00", expected: "0:01" },
                { tag: "0:29->0:30", elpasedTime: 29, initial: "0:29", expected: "0:30" },
                { tag: "0:59->1:00", elpasedTime: 59, initial: "0:59", expected: "1:00" },

                { tag: "01:59->02:00", elpasedTime: 119, initial: "1:59", expected: "2:00" },
                { tag: "59:59->60:00", elpasedTime: 3599, initial: "59:59", expected: "60:00" }
            ];
        }

        function test_timeElapsed(data) {
            callManager.backgroundCall = call1;
            call1.elapsedTime = data.elpasedTime;

            var timeLabel = findChild(callHint, "timeLabel");
            verify(timeLabel !== null);

            compare(timeLabel.text, data.initial);
            call1.elapsedTime = call1.elapsedTime + 1;
            compare(timeLabel.text, data.expected);
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
