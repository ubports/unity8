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

    // Need to do this dynamically.
    // Apparently ListModels dont order roles visually when using ListElement
    // which throws off the filter for non-visible indicators.
    Component.onCompleted: {
        append({    "identifier": "indicator-fake1",
                    "priority": 0,
                    "title": "Menu1",
                    "description": "",
                    "widgetSource": "qrc:/tests/indciators/qml/fake_menu_widget1.qml",
                    "pageSource": "qrc:/tests/indciators/qml/fake_menu_page1.qml",
                    "indicatorProperties": "",
                    "isVisible": true});

        append({    "identifier": "indicator-fake2",
                    "priority": 1,
                    "title": "Menu2",
                    "description": "",
                    "widgetSource": "qrc:/tests/indciators/qml/fake_menu_widget2.qml",
                    "pageSource": "qrc:/tests/indciators/qml/fake_menu_page2.qml",
                    "indicatorProperties": "",
                    "isVisible": true});

        append({    "identifier": "indicator-fake3",
                    "priority": 2,
                    "title": "Menu3",
                    "description": "",
                    "widgetSource": "qrc:/tests/indciators/qml/fake_menu_widget3.qml",
                    "pageSource": "qrc:/tests/indciators/qml/fake_menu_page3.qml",
                    "indicatorProperties": "",
                    "isVisible": true});

        append({    "identifier": "indicator-fake4",
                    "priority": 3,
                    "title": "Menu4",
                    "description": "",
                    "widgetSource": "qrc:/tests/indciators/qml/fake_menu_widget4.qml",
                    "pageSource": "qrc:/tests/indciators/qml/fake_menu_page4.qml",
                    "indicatorProperties": "",
                    "isVisible": true});

        append({    "identifier": "indicator-fake5",
                    "priority": 4,
                    "title": "Menu5",
                    "description": "",
                    "widgetSource": "qrc:/tests/indciators/qml/fake_menu_widget5.qml",
                    "pageSource": "qrc:/tests/indciators/qml/fake_menu_page5.qml",
                    "indicatorProperties": "",
                    "isVisible": true});
    }

    function data(row, role) {
        if (role == Indicators.IndicatorsModelRole.Identifier) {
            return get(row).identifier;
        }
        else if (role == Indicators.IndicatorsModelRole.Priority) {
            return get(row).priority;
        }
        else if (role == Indicators.IndicatorsModelRole.Title) {
            return get(row).title;
        }
        else if (role == Indicators.IndicatorsModelRole.Description) {
            return get(row).description;
        }
        else if (role == Indicators.IndicatorsModelRole.WidgetSource) {
            return get(row).widgetSource;
        }
        else if (role == Indicators.IndicatorsModelRole.PageSource) {
            return get(row).pageSource;
        }
        else if (role == Indicators.IndicatorsModelRole.IndicatorProperties) {
            return get(row).indicatorProperties;
        }
        else if (role == Indicators.IndicatorsModelRole.IsVisible) {
            return get(row).isVisible;
        }
    }

    function setData(row, value, role) {
        if (role == Indicators.IndicatorsModelRole.Identifier) {
            return set(row, {"identifier": value});
        }
        else if (role == Indicators.IndicatorsModelRole.Priority) {
            return set(row, {"priority": value});
        }
        else if (role == Indicators.IndicatorsModelRole.Title) {
            return set(row, {"title": value});
        }
        else if (role == Indicators.IndicatorsModelRole.Description) {
            return set(row, {"description": value});
        }
        else if (role == Indicators.IndicatorsModelRole.WidgetSource) {
            return set(row, {"widgetSource": value});
        }
        else if (role == Indicators.IndicatorsModelRole.PageSource) {
            return set(row, {"pageSource": value});
        }
        else if (role == Indicators.IndicatorsModelRole.IndicatorProperties) {
            return set(row, {"indicatorProperties": value});
        }
        else if (role == Indicators.IndicatorsModelRole.IsVisible) {
            return set(row, {"isVisible": value});
        }
    }

}
