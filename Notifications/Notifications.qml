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
import Ubuntu.Components 0.1
import "../Components"
import "timings.js" as Timings

ListView {
    id: notificationRenderer

    objectName: "notificationRenderer"
    interactive: false

    spacing: units.gu(.5)
    delegate: Notification {
        objectName: "notification" + index
        anchors {
            left: parent.left
            right: parent.right
        }
        type: model.type
        iconSource: model.icon
        secondaryIconSource: model.secondaryIcon
        summary: model.summary
        body: model.body
        actions: model.actions
        notificationId: model.id
        notificationobj: model.notificationobj
    }

    populate: Transition {
        NumberAnimation {
            property: "opacity"
            to: 1
            duration: Timings.snapBeat
            easing.type: Timings.easing
        }
    }

    add: Transition {
        NumberAnimation {
            property: "opacity"
            to: 1
            duration: Timings.snapBeat
            easing.type: Timings.easing
        }
    }

    remove: Transition {
        NumberAnimation {
            property: "opacity"
            to: 0
            duration: Timings.fastBeat
            easing.type: Timings.easing
        }
    }

    displaced: Transition {
        NumberAnimation {
            properties: "x,y"
            duration: Timings.fastBeat
            easing.type: Timings.easing
        }
    }
}
