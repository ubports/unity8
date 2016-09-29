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

import QtQuick 2.4
import Ubuntu.Components 1.3
import "../Panel/Indicators"
import Unity.Indicators 0.1 as Indicators

Item {
    id: clock

    implicitWidth: childrenRect.width
    implicitHeight: childrenRect.height

    // Allows to set the current Date. Will be overwritten if visible
    property date currentDate

    Component.onCompleted: {
        if (visible) {
            currentDate = new Date()
        }
    }

    Connections {
        target: i18n
        onLanguageChanged: {
            if (visible) {
                timeLabel.text = Qt.formatTime(clock.currentDate); // kicks time
                clock.currentDate = new Date(); // kicks date
            }
        }
    }

    Indicators.SharedUnityMenuModel {
        id: timeModel
        objectName: "timeModel"

        busName: "com.canonical.indicator.datetime"
        actions: { "indicator": "/com/canonical/indicator/datetime" }
        menuObjectPath: clock.visible ? "/com/canonical/indicator/datetime/phone" : ""
    }

    Indicators.ModelActionRootState {
        menu: timeModel.model
        onUpdated: {
            if (timeLabel.text != rightLabel) {
                if (rightLabel != "") timeLabel.text = rightLabel;
                clock.currentDate = new Date();
            }
        }
    }

    Column {
        spacing: units.gu(0.5)

        Label {
            id: timeLabel
            objectName: "timeLabel"

            anchors.horizontalCenter: parent.horizontalCenter
            font.pixelSize: units.gu(7.5)
            color: "white"
            text: Qt.formatTime(clock.currentDate)
            font.weight: Font.Light
        }

        Label {
            id: dateLabel
            objectName: "dateLabel"

            anchors.horizontalCenter: parent.horizontalCenter
            fontSize: "medium"
            color: "white"
            text: Qt.formatDate(clock.currentDate, Qt.DefaultLocaleLongDate)
            font.weight: Font.Light
        }
    }
}
