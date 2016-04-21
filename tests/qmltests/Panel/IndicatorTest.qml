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
import QtQuick.Layouts 1.1
import QtTest 1.0
import "../../../qml/Panel"
import Ubuntu.Components 1.3
import Unity.Test 0.1 as UT
import Unity.Indicators 0.1 as Indicators

Rectangle {
    id: root
    color: theme.palette.normal.background
    Component.onCompleted: theme.name = "Ubuntu.Components.Themes.SuruDark"

    property alias indicatorsModel: __indicatorsModel
    property alias originalModelData: __indicatorsModel.originalModelData

    Indicators.IndicatorsModel {
        id: __indicatorsModel
        Component.onCompleted: load();
    }

    function insertIndicator(index) {
        var i;
        var insertIndex = 0;
        var done = false;
        for (i = index; !done && i >= 1; i--) {

            var lookFor = __indicatorsModel.originalModelData[i-1]["identifier"]

            var j;
            for (j = __indicatorsModel.modelData.length-1; !done && j >= 0; j--) {
                if (__indicatorsModel.modelData[j]["identifier"] === lookFor) {
                    insertIndex = j+1;
                    done = true;
                }
            }
        }
        __indicatorsModel.insert(insertIndex, __indicatorsModel.originalModelData[index]);
    }

    function removeIndicator(index) {
        var i;
        for (i = 0; i < __indicatorsModel.modelData.length; i++) {
            if (__indicatorsModel.modelData[i]["identifier"] === __indicatorsModel.originalModelData[index]["identifier"]) {
                __indicatorsModel.remove(i);
                break;
            }
        }
    }

    function setIndicatorVisible(index, visible) {
        var identifier = __indicatorsModel.originalModelData[index]["identifier"];
        __indicatorsModel.setIndicatorVisible(identifier, visible);
    }

    function resetData() {
        __indicatorsModel.load();
    }
}
