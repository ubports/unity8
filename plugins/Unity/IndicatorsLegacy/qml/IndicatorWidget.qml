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
 *      Nick Dedekind <nick.dedekind@canonical.com>
 */

import QtQuick 2.0
import Unity.IndicatorsLegacy 0.1 as Indicators

IndicatorBase {
    id: indicatorWidget

//    enabled: false        // FIXME : should be disabled until bus available when we have desktop indicators
    property var action: undefined
    property bool started: (busType != 0) && (busName != "") && (deviceMenuObjectPath != "")
    property int iconSize: height - units.gu(0.5)
    property string rootMenuType: "com.canonical.indicator.root"

    signal actionStateChanged()

    onStartedChanged: {
        if (started) {
            proxyModel.start();
            actionGroup.start();
        } else {
            proxyModel.stop();
            actionGroup.stop();
        }
    }
    onActionChanged: actionStateChanged()
    onActionGroupUpdated: update_state()
    onModelUpdated: update_state()


    function update_state() {
        var extra = proxyModel.data(0, Indicators.FlatMenuProxyModelRole.Extra);
        if (extra == undefined) {
            return;
        }

        if (!extra.hasOwnProperty("canonical_type")) {
            return;
        }

        if (extra.canonical_type === rootMenuType) {
            action = actionGroup.action(proxyModel.data(0, Indicators.FlatMenuProxyModelRole.Action));
        }
    }

    Connections {
        target: action == undefined ? null : action
        onStateChanged: actionStateChanged()
        onValidChanged: actionStateChanged()
    }
}
