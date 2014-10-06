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

import QtQuick 2.1
import QtQuick.Layouts 1.1
import QtTest 1.0
import "../../../qml/Panel"
import Ubuntu.Components 0.1
import Unity.Test 0.1 as UT
import Unity.Indicators 0.1 as Indicators

Rectangle {
    id: root
    color: "white"

    property alias indicatorsModel: __indicatorsModel
    Indicators.IndicatorsModel {
        id: __indicatorsModel
        Component.onCompleted: load()
    }

    function insertIndicator(index) {
        var i;
        var insertIndex = 0;
        var done = false;
        for (i = index; !done && i >= 1; i--) {

            var lookFor = indicatorsModel.originalModelData[i-1]["identifier"]

            var j;
            for (j = indicatorsModel.modelData.length-1; !done && j >= 0; j--) {
                if (indicatorsModel.modelData[j]["identifier"] === lookFor) {
                    insertIndex = j+1;
                    done = true;
                }
            }
        }
        indicatorsModel.insert(insertIndex, indicatorsModel.originalModelData[index]);
    }

    function removeIndicator(index) {
        var i;
        for (i = 0; i < indicatorsModel.modelData.length; i++) {
            if (indicatorsModel.modelData[i]["identifier"] === indicatorsModel.originalModelData[index]["identifier"]) {
                indicatorsModel.remove(i);
                break;
            }
        }
    }

    function resetData() {
        indicatorsModel.load();
    }
}
