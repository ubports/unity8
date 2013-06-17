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
import Unity.Indicators.Network 0.1 as ICNetwork
import Ubuntu.Components 0.1

PageStack {
    id: _network

    property alias title: _mainPage.title
    property alias emptyText: _pluginItem.emptyText
    property alias busType: _pluginItem.busType
    property alias busName: _pluginItem.busName
    property alias actionsObjectPath : _pluginItem.actionsObjectPath
    property alias menuObjectPaths : _pluginItem.menuObjectPaths

    __showHeader: false
    anchors.fill: parent

    Page {
        id: _mainPage

        Indicators.IndicatorPage {
            id: _pluginItem
            anchors.fill: parent
        }
    }

    Component {
        id: passwordPageComponent

        ICNetwork.PasswordPage {
            agent: networkAgent
            token: token
        }
    }

    ICNetwork.NetworkAgent {
        id: networkAgent

        onSecretRequested: {
            _network.push(passwordPageComponent)
        }
    }

    function start()
    {
        push(_mainPage);
        _pluginItem.start();
    }

    function stop()
    {
        clear();
        _pluginItem.stop();
    }

    function reset()
    {
        _pluginItem.reset();
    }
}
