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
 *
 * Authors: Nick Dedekind <nick.dedekind@canonical.com>
 */

#include "plugin.h"
#include "unitymenumodel.h"
#include "actiondata.h"
#include "actionstateparser.h"
#include "dbus-enums.h"

#include <QtQml/qqml.h>

static QObject* actionDataSingleton(QQmlEngine* engine, QJSEngine* scriptEngine)
{
  Q_UNUSED(engine);
  Q_UNUSED(scriptEngine);
  return new ActionData;
}

void QMenuModelPlugin::registerTypes(const char *uri)
{
    Q_ASSERT(uri == QLatin1String("QMenuModel"));
    qmlRegisterUncreatableType<DBusEnums>(uri, 0, 1, "DBus",
                                          "DBus is only a namespace");
    qmlRegisterType<UnityMenuModel>(uri, 0, 1, "UnityMenuModel");
    qmlRegisterType<ActionStateParser>(uri, 0, 1, "ActionStateParser");

    qmlRegisterSingletonType<ActionData>(uri, 0, 1, "ActionData", actionDataSingleton);
}
