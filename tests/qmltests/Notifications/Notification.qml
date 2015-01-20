/*
 * Copyright 2015 Canonical Ltd.
 *
 * This program is free software; you can redistribute it and/or modify
 * it under the terms of the GNU Lesser General Public License as published by
 * the Free Software Foundation; version 3.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU Lesser General Public License for more details.
 *
 * You should have received a copy of the GNU Lesser General Public License
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.
 *
 * Authors:
 *      Mirco Mueller <mirco.mueller@canonical.com>
 */

import QtQuick 2.0
import QtTest 1.0
import ".."
import "../../../qml/Notifications"
import Ubuntu.Components 0.1
import Unity.Test 0.1
import Unity.Notifications 1.0
import QtMultimedia 5.0

Notification {
    id: bla
    nid: 0
    type: Notification.PlaceHolder
    summary: ""
    body: ""
    icon: ""
    secondaryIcon: ""
    value: 0
    rawActions: []
}
