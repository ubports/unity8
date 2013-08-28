/*
 * Copyright (C) 2013 Canonical, Ltd.
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
#include "fake_gsettings.h"

#include <QtQml/qqml.h>

static QObject* controllerProvider(QQmlEngine* /* engine */, QJSEngine* /* scriptEngine */)
{
    return GSettingsControllerQml::instance();
}

void FakeGSettingsQmlPlugin::registerTypes(const char *uri)
{
    qmlRegisterSingletonType<GSettingsControllerQml>(uri, 1, 0, "GSettingsController", controllerProvider);
    qmlRegisterType<GSettingsQml>(uri, 1, 0, "GSettings");
    qmlRegisterUncreatableType<GSettingsSchemaQml>(uri, 1, 0, "GSettingsSchema",
                                                   "GSettingsSchema can only be used inside of a GSettings component");
}
