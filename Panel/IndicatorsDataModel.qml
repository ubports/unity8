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
import Unity.Indicators 0.1 as Indicators
import Utils 0.1

Indicators.IndicatorsModel {
    id: ic_model

    Component.onCompleted: load()

    indicatorData : {
        'indicator-location' : {
            'title': 'Location',
            'description' : ''
        },
        'indicator-bluetooth' : {
            'title': 'Bluetooth',
            'description' : ''
        },
        'indicator-messages' : {
            'title': 'Messaging',
            'description' : ''
        },
        'indicator-sound' : {
            'title': 'Sound',
            'description' : ''
        },
        'indicator-network' : {
            'title': 'Networks',
            'description' : '',
        },
        'indicator-power' : {
            'title': 'Battery',
            'description' : ''
        },
        'indicator-session' : {
            'title': 'Session',
            'description' : ''
        },
        'indicator-datetime' : {
            'title': 'Date and Time',
            'description' : ''
        }
    }
}
