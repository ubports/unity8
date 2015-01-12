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
import Unity.Indicators 0.1 as Indicators
import Utils 0.1

Item {
    property UnitySortFilterProxyModel model: filterModel

    function initialise(profile) {
        indicatorsModel.load(profile);
    }

    UnitySortFilterProxyModel {
        id: filterModel
        filterRole: Indicators.IndicatorsModelRole.IsVisible
        filterRegExp: RegExp("^true$")
        dynamicSortFilter: true

        model: Indicators.VisibleIndicatorsModel {
            id: visibleIndicatorsModel
            model: indicatorsModel
        }
    }

    Indicators.IndicatorsModel {
        id: indicatorsModel
    }

    Repeater {
        id: repeater
        model: indicatorsModel

        property var visibleIndicators: undefined
        onVisibleIndicatorsChanged: {
            if (visibleIndicators !== undefined) {
                visibleIndicatorsModel.visible = visibleIndicators;
            }
        }

        delegate: IndicatorDelegate {
            id: item
            objectName: model.identifier + "-delegate"
            identifier: model.identifier
            Component.onCompleted: {
                for(var pName in indicatorProperties) {
                    if (item.hasOwnProperty(pName)) {
                        item[pName] = indicatorProperties[pName];
                    }
                }
                updateVisibility();
            }

            onEnabledChanged: {
                updateVisibility()
            }

            function updateVisibility() {
                if (repeater.visibleIndicators === undefined) {
                    repeater.visibleIndicators = {}
                }
                repeater.visibleIndicators[model.identifier] = enabled;
                repeater.visibleIndicatorsChanged();
            }
        }
    }
}
