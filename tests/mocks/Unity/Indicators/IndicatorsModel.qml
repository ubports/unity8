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
import Unity.Indicators 0.1 as Indicators

ListModel {

    property var indicatorData : undefined

    function load() {}

    ListElement {
        identifier: "indicator-fake1";
        priority: 0
        title: "Menu1";
        description: "";
        widgetSource: "qrc:/tests/indciators/qml/fake_menu_widget1.qml";
        pageSource: "qrc:/tests/indciators/qml/fake_menu_page1.qml";
        indicatorProperties: "";
        isValid: "";
    }
    ListElement {
        identifier: "indicator-fake2";
        priority: 1
        title: "Menu2";
        description: "";
        widgetSource: "qrc:/tests/indciators/qml/fake_menu_widget2.qml";
        pageSource: "qrc:/tests/indciators/qml/fake_menu_page2.qml";
        indicatorProperties: "";
        isValid: "";
    }
    ListElement {
        identifier: "indicator-fake3";
        priority: 2
        title: "Menu3";
        description: "";
        widgetSource: "qrc:/tests/indciators/qml/fake_menu_widget3.qml";
        pageSource: "qrc:/tests/indciators/qml/fake_menu_page3.qml";
        indicatorProperties: "";
        isValid: "";
    }
    ListElement {
        identifier: "indicator-fake4";
        priority: 3
        title: "Menu4";
        description: "";
        widgetSource: "qrc:/tests/indciators/qml/fake_menu_widget4.qml";
        pageSource: "qrc:/tests/indciators/qml/fake_menu_page4.qml";
        indicatorProperties: "";
        isValid: "";
    }
    ListElement {
        identifier: "indicator-fake5";
        priority: 4
        title: "Menu5";
        description: "";
        widgetSource: "qrc:/tests/indciators/qml/fake_menu_widget5.qml";
        pageSource: "qrc:/tests/indciators/qml/fake_menu_page5.qml";
        indicatorProperties: "";
        isValid: "";
    }

    function data(row, role) {
        if (role == Indicators.IndicatorsModelRole.Identifier) {
            return get(row).identifier;
        }
        else if (role == Indicators.IndicatorsModelRole.Priority) {
            return get(row).priority
        }
        else if (role == Indicators.IndicatorsModelRole.Title) {
            return get(row).title
        }
        else if (role == Indicators.IndicatorsModelRole.Description) {
            return get(row).description
        }
        else if (role == Indicators.IndicatorsModelRole.WidgetSource) {
            return get(row).widgetSource
        }
        else if (role == Indicators.IndicatorsModelRole.PageSource) {
            return get(row).pageSource
        }
        else if (role == Indicators.IndicatorsModelRole.IndicatorProperties) {
            return get(row).indicatorProperties
        }
        else if (role == Indicators.IndicatorsModelRole.IsValid) {
            return get(row).isValid
        }
    }

}
