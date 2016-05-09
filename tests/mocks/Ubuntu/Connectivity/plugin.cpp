/*
 * Copyright © 2014 Canonical Ltd.
 *
 * This program is free software: you can redistribute it and/or modify it
 * under the terms of the GNU Lesser General Public License version 3,
 * as published by the Free Software Foundation.
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
 *     Antti Kaijanmäki <antti.kaijanmaki@canonical.com>
 */

#include "plugin.h"

#include <QtQml>

#include "networking-status.h"

static QObject *
networkingStatusSingletonProvider(QQmlEngine *engine, QJSEngine *scriptEngine)
{
    Q_UNUSED(scriptEngine)

    return new NetworkingStatus(engine);
}

void
QmlConnectivityNetworkingPlugin::registerTypes(const char *uri)
{
    // @uri Ubuntu.Connectivity
    qmlRegisterSingletonType<NetworkingStatus>(uri, 1, 0, "NetworkingStatus", networkingStatusSingletonProvider);
    qmlRegisterSingletonType<NetworkingStatus>(uri, 1, 0, "Connectivity", networkingStatusSingletonProvider);
}

void
QmlConnectivityNetworkingPlugin::initializeEngine(QQmlEngine *engine, const char *uri)
{
  Q_UNUSED(uri);
  Q_UNUSED(engine);
}
