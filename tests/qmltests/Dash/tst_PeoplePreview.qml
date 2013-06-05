/*
 * Copyright 2013 Canonical Ltd.
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
import ".."
import "../../../Dash/People"
import Ubuntu.Components 0.1
import Unity.Test 0.1 as UT

Item {
    id: root
    width: units.gu(140)
    height: units.gu(100)

    property bool helper: false

    PeoplePreview {
        id: preview
        anchors.fill: parent
        anchors.rightMargin: units.gu(20)
    }

    Column {
        anchors {
            left: preview.right
            top: parent.top
            right: parent.right
            bottom: parent.bottom
            margins: units.gu(1)
        }
        spacing: units.gu(1)

        Button {
            text: "Clear all"
            anchors { left: parent.left; right: parent.right }
            onClicked: mockModel.clear();
        }
        Repeater {
            model: testCase.test_click_items_data()
            Button {
                text: testCase.test_click_items_data()[index].tag
                anchors { left: parent.left; right: parent.right }
                onClicked: testCase.fillModel(testCase.test_click_items_data()[index]);
            }
        }
    }

    ListModel {
        id: mockModel
    }

    SignalSpy {
        id: clickSpy
        signalName: "clicked"
    }

    UT.UnityTestCase {
        id: testCase
        name: "PeoplePreview"
        when: windowShown

        function fillModel(data) {
            mockModel.clear();
            mockModel.append(data);
            preview.model = mockModel.get(0);
            wait(0);
        }

        function test_click_items_data() {
            return [
                        {
                            tag: "All Data",
                            displayName: "Round Robin",
                            avatar: "../../graphics/clock.png",
                            status: "very busy",
                            statusTime: "1/6/2013 16:19:01",
                            statusServiceIcon: "../../../graphics/clock.png",
                            phoneNumbers: [{number:"123456", type: "voice", location: "Mars"}, {number: "654321"}],
                            emailAddresses: [{address:"robin@ntp.org"}, {address: "sirspamalot@foo.com"}],
                            imAccounts: [{address:"rr@jabber.org", protocol: "xmpp"}, {address: "sirspamalot@foo.com", protocol: "secret service messenger"}],
                            addresses: [
                                {street: "Middle of nowhere", poBox: 1, extension: "none", locality: "Mars", region: "all of it", postalCode: "٣٤٥٦", country: "There is only one on mars", addressFormat: "unreadable for you"},
                                {street: "Blue fin building"}
                            ]
                        },
                        {
                            tag: "Only Status",
                            status: "very busy",
                            statusTime: "1/6/2013 16:19:01",
                            statusServiceIcon: "../../../graphics/clock.png",
                        },
                        {
                            tag: "One Number",
                            phoneNumbers: [{number:"123456", type: "voice", location: "Mars"}],
                        },
                        {
                            tag: "Three Numbers",
                            phoneNumbers: [{number:"123456", type: "voice", location: "Mars"}, {number: "654321"}, {number: "666", type: "voice", location: "h3ll"}],
                        },
                        {
                            tag: "Only Mails",
                            emailAddresses: [{address:"robin@ntp.org"}, {address: "sirspamalot@foo.com"}],
                        },
                        {
                            tag: "Only IM",
                            imAccounts: [{address:"rr@jabber.org", protocol: "xmpp"}, {address: "sirspamalot@foo.com", protocol: "secret service messenger"}],
                        },
                        {
                            tag: "Only Address",
                            addresses: [
                                {street: "Middle of nowhere", poBox: 1, extension: "none", locality: "Mars", region: "all of it", postalCode: "٣٤٥٦", country: "There is only one on mars", addressFormat: "unreadable for you"},
                            ]
                        },
                        {
                            tag: "Std Contact",
                            displayName: "Round Robin",
                            avatar: "../../graphics/clock.png",
                            phoneNumbers: [{number:"123456", type: "voice", location: "Mars"}],
                            emailAddresses: [{address:"robin@ntp.org"}],
                            addresses: [
                                {street: "Middle of nowhere", poBox: 1, extension: "none", locality: "Mars", region: "all of it", postalCode: "٣٤٥٦", country: "There is only one on mars", addressFormat: "unreadable for you"},
                                {street: "Blue fin building"}
                            ]
                        },
                        {
                            tag: "Std + Status",
                            displayName: "Round Robin",
                            avatar: "../../graphics/clock.png",
                            status: "very busy",
                            statusTime: "1/6/2013 16:19:01",
                            statusServiceIcon: "../../../graphics/clock.png",
                            phoneNumbers: [{number:"123456", type: "voice", location: "Mars"}],
                            emailAddresses: [{address:"robin@ntp.org"}],
                            addresses: [
                                {street: "Middle of nowhere", poBox: 1, extension: "none", locality: "Mars", region: "all of it", postalCode: "٣٤٥٦", country: "There is only one on mars", addressFormat: "unreadable for you"},
                                {street: "Blue fin building"}
                            ]
                        },
                    ]
        }

        function test_click_items(data) {
            fillModel(data)

            // Check if status field is visible
            var field = findChild(preview, "statusField");
            if (data.status != undefined) {
                compare(field.visible, true, "status field is not visible");
                verifyClick(field);
            } else {
                compare(field.visible, false, "status field is visible while it should not");
            }

            // Check if there are phoneNumber.count phone fields
            var i = 0;
            if (data.phoneNumbers != undefined) {
                for (; i < data.phoneNumbers.length; ++i) {
                    var field = findChild(preview, "phoneField" + i);
                    verify(field != undefined);
                    verifyPhoneNumberClick(field);
                }
                i++;
            }
            // Check if there are no more phone fields
            var field = findChild(preview, "phoneField" + i);
            compare(field, undefined, "There is a phone number field too much!");


            // Check if email adresses are here
            var i = 0;
            if (data.emailAddresses != undefined) {
                for (; i < data.emailAddresses.length; ++i) {
                    var field = findChild(preview, "emailField" + i);
                    verify(field != undefined);
                    verifyClick(field);
                }
                i++;
            }
            // Check if there are no more email fields
            var field = findChild(preview, "emailField" + i);
            compare(field, undefined, "There is a email field too much!");


            // Check if IM accounts are here
            var i = 0;
            if (data.imAccounts != undefined) {
                for (; i < data.imAccounts.length; ++i) {
                    var field = findChild(preview, "imField" + i);
                    verify(field != undefined);
                    verifyClick(field);
                }
                i++;
            }
            // Check if there are no more IM fields
            var field = findChild(preview, "imField" + i);
            compare(field, undefined, "There is a IM field too much!");

            // Check if email adresses are here
            var i = 0;
            if (data.addresses != undefined) {
                for (; i < data.addresses.length; ++i) {
                    var field = findChild(preview, "addressField" + i);
                    verify(field != undefined);
                    verifyClick(field);
                }
                i++;
            }
            // Check if there are no more fields fields
            var field = findChild(preview, "addressField" + i);
            compare(field, undefined, "There is an address field too much!");
        }

        function verifyClick(field) {
            waitForRendering(field)
            clickSpy.signalName = "" // Get rid of a warning if new target doesn't support previous signal name
            clickSpy.target = field;
            clickSpy.clear();
            clickSpy.signalName = "clicked";
            compare(clickSpy.count, 0, "Could not reset signal spy");
            mouseClick(field, field.width / 2, field.height / 2);
            compare(clickSpy.count, 1, "Could not click on field " + field);
        }

        function verifyPhoneNumberClick(field) {
            waitForRendering(field)
            clickSpy.target = field;
            clickSpy.clear();
            clickSpy.signalName = "phoneClicked";
            compare(clickSpy.count, 0, "Could not reset signal spy");
            mouseClick(field, 1 , field.height / 2);
            compare(clickSpy.count, 1, "Could not click on phone field");

            clickSpy.clear();
            clickSpy.signalName = "textClicked";
            compare(clickSpy.count, 0, "Could not reset signal spy");
            mouseClick(field, field.width - 1 , field.height / 2);
            compare(clickSpy.count, 1, "Could not click on Message field");
        }
    }
}
