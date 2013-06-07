/*
 * Copyright (C) 2013 Canonical, Ltd.
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

ListModel {

    property var indicatorData : undefined

    function load() {}

    ListElement {
        identifier: "indicator-fake1";
        priority: 0
        title: "Menu1";
        description: "";
        iconQml: "qrc:/tests/indciatorsclient/qml/fake_menu_icon1.qml";
        pageQml: "qrc:/tests/indciatorsclient/qml/fake_menu_page1.qml";
        indicatorProperties: "";
        isValid: "";
    }
    ListElement {
        identifier: "indicator-fake2";
        priority: 1
        title: "Menu2";
        description: "";
        iconQml: "qrc:/tests/indciatorsclient/qml/fake_menu_icon2.qml";
        pageQml: "qrc:/tests/indciatorsclient/qml/fake_menu_page2.qml";
        indicatorProperties: "";
        isValid: "";
    }
    ListElement {
        identifier: "indicator-fake3";
        priority: 2
        title: "Menu3";
        description: "";
        iconQml: "qrc:/tests/indciatorsclient/qml/fake_menu_icon3.qml";
        pageQml: "qrc:/tests/indciatorsclient/qml/fake_menu_page3.qml";
        indicatorProperties: "";
        isValid: "";
    }
    ListElement {
        identifier: "indicator-fake4";
        priority: 3
        title: "Menu4";
        description: "";
        iconQml: "qrc:/tests/indciatorsclient/qml/fake_menu_icon4.qml";
        pageQml: "qrc:/tests/indciatorsclient/qml/fake_menu_page4.qml";
        indicatorProperties: "";
        isValid: "";
    }
    ListElement {
        identifier: "indicator-fake4";
        priority: 4
        title: "Menu5";
        description: "";
        iconQml: "qrc:/tests/indciatorsclient/qml/fake_menu_icon5.qml";
        pageQml: "qrc:/tests/indciatorsclient/qml/fake_menu_page5.qml";
        indicatorProperties: "";
        isValid: "";
    }

}
