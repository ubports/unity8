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
import Unity.Notifications 1.0 as UnityNotifications
import Utils 0.1
import "../Components"

ListView {
    id: notificationList

    objectName: "notificationList"
    interactive: false

    property real margin
    property bool useModal: snapDecisionProxyModel.count > 0
    property bool hasMouse

    UnitySortFilterProxyModel {
        id: snapDecisionProxyModel
        objectName: "snapDecisionProxyModel"

        model: notificationList.model ? notificationList.model : null
        filterRole: UnityNotifications.ModelInterface != undefined ? UnityNotifications.ModelInterface.RoleType : 0
        filterRegExp: RegExp(UnityNotifications.Notification.SnapDecision)
    }

    property bool topmostIsFullscreen: false
    spacing: topmostIsFullscreen ? 0 : units.gu(.5)

    currentIndex: count > 1 ? 1 : -1

    delegate: Notification {
        objectName: "notification" + index
        width: parent.width
        type: model.type
        hints: model.hints
        iconSource: model.icon
        secondaryIconSource: model.secondaryIcon
        summary: model.summary
        body: model.body
        value: model.value ? model.value : -1
        actions: model.actions
        notificationId: model.id
        notification: notificationList.model.getRaw(notificationId)
        maxHeight: notificationList.height
        margins: notificationList.margin
        hasMouse: notificationList.hasMouse

        // make sure there's no opacity-difference between the several
        // elements in a notification
        // FIXME: disabled all transitions because of LP: #1354406 workaround
        //layer.enabled: add.running || remove.running || populate.running

        Component.onCompleted: {
            if (index == 1) {
                notificationList.topmostIsFullscreen = fullscreen
            }
        }

        onFullscreenChanged: {
            // index 1 because 0 is the PlaceHolder...
            if (index == 1) {
                notificationList.topmostIsFullscreen = fullscreen
            }
        }
    }

    // FIXME: disabled all transitions because of LP: #1354406 workaround
    /*populate: Transition {
        UbuntuNumberAnimation {
            property: "opacity"
            to: 1
            duration: UbuntuAnimation.SnapDuration
        }
    }

    add: Transition {
        UbuntuNumberAnimation {
            property: "opacity"
            to: 1
            duration: UbuntuAnimation.SnapDuration
        }
    }

    remove: Transition {
        UbuntuNumberAnimation {
            property: "opacity"
            to: 0
        }
    }

    displaced: Transition {
        UbuntuNumberAnimation {
            properties: "x,y"
            duration: UbuntuAnimation.SnapDuration
        }
    }*/
}
