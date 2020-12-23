/*
 * Copyright (C) 2021 UBports Foundation.
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
 * Authors: Alberto Mardegan <mardy@users.sourceforge.net>
 */

#include "plugin.h"

#include "LocationWatcher.h"
#include "ProcessControl.h"

#include <QQmlEngine>

static QObject *service_provider(QQmlEngine *engine, QJSEngine *scriptEngine)
{
    Q_UNUSED(engine);
    Q_UNUSED(scriptEngine);

    ProcessControl *processControl = new ProcessControl();
    new LocationWatcher(processControl);

    return processControl;
}

void ProcessControlPlugin::registerTypes(const char *uri)
{
    Q_ASSERT(uri == QLatin1String("ProcessControl"));
    qmlRegisterSingletonType<ProcessControl>(uri, 0, 1, "ProcessControl", service_provider);
}
