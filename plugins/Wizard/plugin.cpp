/*
 * Copyright (C) 2014 Canonical Ltd.
 *
 * This program is free software: you can redistribute it and/or modify it
 * under the terms of the GNU General Public License version 3, as published
 * by the Free Software Foundation.
 *
 * This program is distributed in the hope that it will be useful, but
 * WITHOUT ANY WARRANTY; without even the implied warranties of
 * MERCHANTABILITY, SATISFACTORY QUALITY, or FITNESS FOR A PARTICULAR
 * PURPOSE.  See the GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License along
 * with this program.  If not, see <http://www.gnu.org/licenses/>.
 */

#include "plugin.h"
#include "PageList.h"
#include "System.h"
#include "timezonemodel.h"
#include "LocalePlugin.h"
#include "Status.h"

#include <QtQml/qqml.h>

void WizardPlugin::registerTypes(const char *uri)
{
    Q_ASSERT(uri == QLatin1String("Wizard"));
    qmlRegisterType<PageList>(uri, 0, 1, "PageList");
    qmlRegisterSingletonType<System>(uri, 0, 1, "System", [](QQmlEngine*, QJSEngine*) -> QObject* { return new System; });
    qmlRegisterSingletonType<Status>(uri, 0, 1, "Status", [](QQmlEngine*, QJSEngine*) -> QObject* { return new Status; });
    qmlRegisterType<TimeZoneLocationModel>(uri, 0, 1, "TimeZoneModel");
    qmlRegisterType<LocalePlugin>(uri, 0, 1, "LocalePlugin");
}
