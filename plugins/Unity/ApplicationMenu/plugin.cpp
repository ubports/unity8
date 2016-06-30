/*
 * Copyright (C) 2016 Canonical, Ltd.
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

#include "plugin.h"
#include "dbusapplicationmenuregistry.h"

#include <QtQml>

static QObject *menuRegistry(QQmlEngine *engine, QJSEngine *scriptEngine)
{
    Q_UNUSED(engine)
    Q_UNUSED(scriptEngine)
    return DBusApplicationMenuRegistry::instance();
}

void ApplicationMenuPlugin::registerTypes(const char *uri)
{
    Q_ASSERT(uri == QLatin1String("Unity.ApplicationMenu"));

    qmlRegisterUncreatableType<MenuServicePath>(uri, 0, 1, "MenuServicePath", "You cannot create a MenuServicePath");
    qmlRegisterSingletonType<DBusApplicationMenuRegistry>(uri, 0, 1, "ApplicationMenuRegistry", menuRegistry);
}

void ApplicationMenuPlugin::initializeEngine(QQmlEngine *engine, const char *uri)
{
    QQmlExtensionPlugin::initializeEngine(engine, uri);

    menuRegistry(nullptr, nullptr);
}
