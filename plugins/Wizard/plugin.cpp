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

static QObject *system_provider(QQmlEngine *engine, QJSEngine *scriptEngine)
{
    Q_UNUSED(engine)
    Q_UNUSED(scriptEngine)
    return new System();
}

static QObject *status_provider(QQmlEngine *engine, QJSEngine *scriptEngine)
{
    Q_UNUSED(engine)
    Q_UNUSED(scriptEngine)
    return new Status();
}

void WizardPlugin::registerTypes(const char *uri)
{
    Q_ASSERT(uri == QLatin1String("Wizard"));
    qmlRegisterType<PageList>(uri, 0, 1, "PageList");
    qmlRegisterSingletonType<System>(uri, 0, 1, "System", system_provider);
    qmlRegisterSingletonType<Status>(uri, 0, 1, "Status", status_provider);
    qmlRegisterType<TimeZoneModel>(uri, 0, 1, "TimeZoneModel");
    qmlRegisterType<TimeZoneFilterModel>(uri, 0, 1, "TimeZoneFilterModel");
    qmlRegisterType<LocalePlugin>(uri, 0, 1, "LocalePlugin");
}
