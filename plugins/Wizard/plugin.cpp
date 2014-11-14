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

#include <QtQml/qqml.h>

static QObject *pagelist_provider(QQmlEngine *engine, QJSEngine *scriptEngine)
{
    Q_UNUSED(engine)
    Q_UNUSED(scriptEngine)
    return new PageList();
}

static QObject *system_provider(QQmlEngine *engine, QJSEngine *scriptEngine)
{
    Q_UNUSED(engine)
    Q_UNUSED(scriptEngine)
    return new System();
}

void WizardPlugin::registerTypes(const char *uri)
{
    Q_ASSERT(uri == QLatin1String("Wizard"));
    qmlRegisterSingletonType<PageList>(uri, 0, 1, "PageList", pagelist_provider);
    qmlRegisterSingletonType<System>(uri, 0, 1, "System", system_provider);
}
