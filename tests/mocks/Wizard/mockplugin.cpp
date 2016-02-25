/*
 * Copyright (C) 2012,2013 Canonical, Ltd.
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

#include "mockplugin.h"
#include "MockSystem.h"
#include "PageList.h"
#include "timezonemodel.h"
#include "LocalePlugin.h"
#include "Status.h"

#include <QtQml/qqml.h>

void MockWizardPlugin::registerTypes(const char *uri)
{
    Q_ASSERT(uri == QLatin1String("Wizard"));
    qmlRegisterType<PageList>(uri, 0, 1, "PageList");
    qmlRegisterSingletonType<MockSystem>(uri, 0, 1, "System", [](QQmlEngine*, QJSEngine*) -> QObject* { return new MockSystem; });
    qmlRegisterSingletonType<Status>(uri, 0, 1, "Status", [](QQmlEngine*, QJSEngine*) -> QObject* { return new Status; });
    qmlRegisterType<TimeZoneLocationModel>(uri, 0, 1, "TimeZoneModel");
    qmlRegisterType<LocalePlugin>(uri, 0, 1, "LocalePlugin");
}
