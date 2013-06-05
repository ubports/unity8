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
#include "ApplicationInfo.h"
#include "ApplicationImage.h"
#include "ApplicationListModel.h"
#include "ApplicationManager.h"

#include <qqml.h>

static QObject* applicationManagerSingleton(QQmlEngine* engine, QJSEngine* scriptEngine) {
  Q_UNUSED(engine);
  Q_UNUSED(scriptEngine);
  return new ApplicationManager();
}

void FakeUbuntuApplicationQmlPlugin::registerTypes(const char *uri)
{
    qmlRegisterSingletonType<ApplicationManager>(
            uri, 0, 1, "ApplicationManager", applicationManagerSingleton);
    qmlRegisterType<ApplicationInfo>(uri, 0, 1, "ApplicationInfo");
    qmlRegisterType<ApplicationImage>(uri, 0, 1, "ApplicationImage");
    qmlRegisterType<ApplicationListModel>(uri, 0, 1, "ApplicationListModel");
}
