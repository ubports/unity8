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
        'indicator-messaging' : {
            'title': 'Messaging',
            'description' : '',
            'widgetSource' : ApplicationPaths.shellAppDirectory()+'/Panel/Indicators/MessagingIndicatorWidget.qml',
            'pageSource' : ApplicationPaths.shellAppDirectory()+'/Panel/Indicators/MessagingIndicatorPage.qml'
        },
        'indicator-sound' : {
            'title': 'Sound',
            'description' : '',
            'widgetSource' : ApplicationPaths.shellAppDirectory()+'/Panel/Indicators/SoundIndicatorWidget.qml',
            'pageSource' : ApplicationPaths.shellAppDirectory()+'/Panel/Indicators/DefaultIndicatorPage.qml'
        },
        'indicator-network' : {
            'title': 'Networks',
            'description' : '',
            'widgetSource' : ApplicationPaths.shellAppDirectory()+'/Panel/Indicators/NetworkIndicatorWidget.qml',
            'pageSource' : ApplicationPaths.shellAppDirectory()+'/Panel/Indicators/NetworkIndicatorPage.qml'
        },
        'indicator-battery' : {
            'title': 'Battery',
            'description' : '',
            'widgetSource' : ApplicationPaths.shellAppDirectory()+'/Panel/Indicators/DefaultIndicatorWidget.qml',
            'pageSource' : ApplicationPaths.shellAppDirectory()+'/Panel/Indicators/DefaultIndicatorPage.qml'
        },
        'indicator-time' : {
            'title': 'Date and Time',
            'description' : '',
            'widgetSource' : ApplicationPaths.shellAppDirectory()+'/Panel/Indicators/DatetimeIndicatorWidget.qml',
            'pageSource' : ApplicationPaths.shellAppDirectory()+'/Panel/Indicators/DatetimeIndicatorPage.qml'
        }
    }
}
