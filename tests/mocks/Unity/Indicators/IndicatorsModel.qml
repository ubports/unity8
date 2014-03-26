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

Indicators.FakeIndicatorsModel {

    function load(profile) {
        unload();

        append({    "identifier": "indicator-fake1",
                    "position": 0,
                    "widgetSource": "qrc:/tests/indciators/qml/fake_menu_widget1.qml",
                    "pageSource": "qrc:/tests/indciators/qml/fake_menu_page1.qml",
                    "indicatorProperties": { enabled: true }
        });

        append({    "identifier": "indicator-fake2",
                    "position": 1,
                    "widgetSource": "qrc:/tests/indciators/qml/fake_menu_widget2.qml",
                    "pageSource": "qrc:/tests/indciators/qml/fake_menu_page2.qml",
                    "indicatorProperties": { enabled: true }
        });

        append({    "identifier": "indicator-fake3",
                    "position": 2,
                    "widgetSource": "qrc:/tests/indciators/qml/fake_menu_widget3.qml",
                    "pageSource": "qrc:/tests/indciators/qml/fake_menu_page3.qml",
                    "indicatorProperties": { enabled: true }
        });

        append({    "identifier": "indicator-fake4",
                    "position": 3,
                    "widgetSource": "qrc:/tests/indciators/qml/fake_menu_widget4.qml",
                    "pageSource": "qrc:/tests/indciators/qml/fake_menu_page4.qml",
                    "indicatorProperties": { enabled: true }
        });

        append({    "identifier": "indicator-fake5",
                    "position": 4,
                    "widgetSource": "qrc:/tests/indciators/qml/fake_menu_widget5.qml",
                    "pageSource": "qrc:/tests/indciators/qml/fake_menu_page5.qml",
                    "indicatorProperties": { enabled: true }
        });
    }
}
