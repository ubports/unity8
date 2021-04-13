/*
 * Copyright (C) 2014 Canonical, Ltd.
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
 *
 * Authors: Ying-Chun Liu (PaulLiu) <paul.liu@canonical.com>
 */

#include "plugin.h"
#include "dbuslomirisessionservice.h"
#include "orientationlock.h"

#include <QAbstractItemModel>
#include <QDBusConnection>
#include <QtQml/qqml.h>

static QObject *dbuslomirisessionservice_provider(QQmlEngine */*engine*/, QJSEngine */*jsEngine*/)
{
    new DBusGnomeSessionManagerDialogWrapper();
    new DBusGnomeSessionManagerWrapper();
    new DBusGnomeScreensaverWrapper();
    new DBusScreensaverWrapper();
    return new DBusLomiriSessionService();
}

static QObject *orientationlock_provider(QQmlEngine */*engine*/, QJSEngine */*jsEngine*/)
{
    return new OrientationLock();
}

void SessionPlugin::registerTypes(const char *uri)
{
    qmlRegisterType<QAbstractItemModel>();

    Q_ASSERT(uri == QLatin1String("Lomiri.Session"));
    qmlRegisterSingletonType<DBusLomiriSessionService>(uri, 0, 1, "DBusLomiriSessionService", dbuslomirisessionservice_provider);
    qmlRegisterSingletonType<OrientationLock>(uri, 0, 1, "OrientationLock", orientationlock_provider);
}
