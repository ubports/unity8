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

import QtQuick 2.4
import QtTest 1.0
import Unity.Test 0.1 as UT
import QMenuModel 0.1
import Utils 0.1 as Utils
import "../../../../qml/Panel/Indicators"

Item {
    id: testView
    width: units.gu(40)
    height: units.gu(70)

    MessageMenuItemFactory {
        id: factory
        menuModel: UnityMenuModel {}
        menuIndex: 0
    }

    UT.UnityTestCase {
        name: "MessageMenuItemFactory"
        when: windowShown

        property QtObject menuData: QtObject {
            property string label: "root"
            property bool sensitive: true
            property bool isSeparator: false
            property string icon: ""
            property string type: ""
            property var ext: undefined
            property string action: ""
            property var actionState: undefined
            property bool isCheck: false
            property bool isRadio: false
            property bool isToggled: false
        }

        function init() {
            menuData.label = "";
            menuData.sensitive = true;
            menuData.isSeparator = false;
            menuData.icon = "";
            menuData.type = "";
            menuData.ext = undefined;
            menuData.action = "";
            menuData.actionState = undefined;
            menuData.isCheck = false;
            menuData.isRadio = false;
            menuData.isToggled = false;

            factory.menuData = null;
        }

        function test_create_simpleTextmessage_data() {
            return [
                { title: "Title1", time: new Date(2013, 10, 10), body: "This is a text message 1", avatar: "file:///avatar1", icon: "file:///appIcon1", enabled: true},
                { title: "Title2", time: new Date(2014, 12, 10), body: "This is a text message 2", avatar: "file:///avatar2", icon: "file:///appIcon2", enabled: false},
            ];
        }

        function test_create_simpleTextmessage(data) {
            menuData.type = "com.canonical.indicator.messages.messageitem";
            menuData.label = data.title;
            menuData.sensitive = data.enabled;
            menuData.ext = {
                'xCanonicalTime': data.time.getTime()*1000, // expected in microseconds
                'xCanonicalText': data.body,
                'icon': data.avatar,
                'xCanonicalAppIcon': data.icon,
            };
            factory.menuData = menuData;

            tryCompare(factory.item, "objectName", "simpleTextMessage");
            compare(factory.item.title, data.title, "Title does not match data");
            compare(factory.item.time, i18n.relativeDateTime(data.time), "Time does not match data");
            compare(factory.item.body, data.body, "Message does not match data");
            compare(factory.item.avatar, data.avatar, "Avatar does not match data");
            compare(factory.item.icon, data.icon, "App icon does not match data");
            compare(factory.item.enabled, data.enabled, "Enabled does not match data");
        }

        function test_create_textmessage_data() {
            return [
                { title: "Title1", time: new Date(2013, 10, 10), body: "This is a text message 1", avatar: "file:///avatar1", icon: "file:///appIcon1", enabled: true},
                { title: "Title2", time: new Date(2014, 12, 10), body: "This is a text message 2", avatar: "file:///avatar2", icon: "file:///appIcon2", enabled: false},
            ];
        }

        function test_create_textmessage(data) {
            menuData.type = "com.canonical.indicator.messages.messageitem";
            menuData.label = data.title;
            menuData.sensitive = data.enabled;
            menuData.ext = {
                'xCanonicalTime': data.time.getTime()*1000, // expected in microseconds
                'xCanonicalText': data.body,
                'icon': data.avatar,
                'xCanonicalAppIcon': data.icon,
                'xCanonicalMessageActions': [{
                        'parameter-type': "s",
                        'name': "action::reply",
                        'label': "Reply1"
                    }
                ]
            };
            factory.menuData = menuData;

            tryCompare(factory.item, "objectName", "textMessage");
            compare(factory.item.title, data.title, "Title does not match data");
            compare(factory.item.time, i18n.relativeDateTime(data.time), "Time does not match data");
            compare(factory.item.body, data.body, "Message does not match data");
            compare(factory.item.avatar, data.avatar, "Avatar does not match data");
            compare(factory.item.icon, data.icon, "App icon does not match data");
            compare(factory.item.enabled, data.enabled, "Enabled does not match data");
        }


        function test_create_snapDecision_data() {
            return [
                { title: "Title1", time: new Date(2013, 10, 10), body: "This is a text message 1", avatar: "file:///avatar1", icon: "file:///appIcon1", enabled: true},
                { title: "Title2", time: new Date(2014, 12, 10), body: "This is a text message 2", avatar: "file:///avatar2", icon: "file:///appIcon2", enabled: false},
            ];
        }

        function test_create_snapDecision(data) {
            menuData.type = "com.canonical.indicator.messages.messageitem";
            menuData.label = data.title;
            menuData.sensitive = data.enabled;
            menuData.ext = {
                'xCanonicalTime': data.time.getTime()*1000, // expected in microseconds
                'xCanonicalText': data.body,
                'icon': data.avatar,
                'xCanonicalAppIcon': data.icon,
                'xCanonicalMessageActions': [{
                        'name': "action::callback",
                        'label': "Callback1"
                    },{
                        'parameter-type': "s",
                        'name': "action::reply",
                        'label': "Reply1"
                    }
                ]
            };
            factory.menuData = menuData;

            tryCompare(factory.item, "objectName", "snapDecision");
            compare(factory.item.title, data.title, "Title does not match data");
            compare(factory.item.time, i18n.relativeDateTime(data.time), "Time does not match data");
            compare(factory.item.body, data.body, "Message does not match data");
            compare(factory.item.avatar, data.avatar, "Avatar does not match data");
            compare(factory.item.icon, data.icon, "App icon does not match data");
            compare(factory.item.enabled, data.enabled, "Enabled does not match data");
        }

    }
}
