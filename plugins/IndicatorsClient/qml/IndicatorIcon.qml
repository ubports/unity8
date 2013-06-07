/*
 * Copyright 2013 Canonical Ltd.
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
 *      Renato Araujo Oliveira Filho <renato@canonical.com>
 */

import QtQuick 2.0
import QMenuModel 0.1
import Ubuntu.Components 0.1
import Ubuntu.Components.ListItems 0.1 as ListItem

IndicatorBase {
    id: indicatorIcon
    property var action: undefined
    property bool started: (busType != 0) && (busName != "") && (objectPath != "")

    signal actionStateChanged()

    onStartedChanged: {
        if (started) {
            proxyModel.start()
            actionGroup.start()
        }
        else {
            proxyModel.stop()
            actionGroup.stop()
        }
    }
    onActionChanged: actionStateChanged()
    onActionGroupUpdated: update_state()
    onModelUpdated: update_state()

    function update_state() {
        var data = proxyModel.get(0)
        if (data == undefined || data.extra == undefined) {
            return
        }

        if (!data.extra.hasOwnProperty("canonical_type")) {
            return;
        }

        if (parseRootElement(data.extra.canonical_type, data)) {
            action = actionGroup.action(data.action)
        }
    }

    function parseRootElement(type, data) {
        if (type == "com.canonical.indicator.root")
            return true;
        return false;
    }

    Connections {
        target: action == undefined ? null : action
        onStateChanged: actionStateChanged()
        onValidChanged: actionStateChanged()
    }
}

