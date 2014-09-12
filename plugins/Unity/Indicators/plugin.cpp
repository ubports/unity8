/*
 * Copyright 2013 Canonical Ltd.
 *
 * This program is free software; you can redistribute it and/or modify
 * it under the terms of the GNU Lesser General Public License as published by
 * the Free Software Foundation; version 3.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU Lesser General Public License for more details.
 *
 * You should have received a copy of the GNU Lesser General Public License
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.
 *
 * Authors:
 *      Nick Dedekind <nick.dedekind@canonical.com>
 */

// Qt
#include <QtQml/qqml.h>

// self
#include "plugin.h"

// local
#include "indicators.h"
#include "indicatorsmanager.h"
#include "indicatorsmodel.h"
#include "menucontentactivator.h"
#include "modelprinter.h"
#include "rootactionstate.h"
#include "sharedunitymenumodel.h"
#include "unitymenumodelcache.h"
#include "unitymenumodelstack.h"
#include "visibleindicatorsmodel.h"

static QObject* menuModelCacheSingleton(QQmlEngine* engine, QJSEngine* scriptEngine) {
  Q_UNUSED(engine);
  Q_UNUSED(scriptEngine);
  return UnityMenuModelCache::singleton();
}

void Indicators2Plugin::registerTypes(const char *uri)
{
    Q_INIT_RESOURCE(indicators);

    qmlRegisterType<IndicatorsManager>(uri, 0, 1, "IndicatorsManager");
    qmlRegisterType<IndicatorsModel>(uri, 0, 1, "IndicatorsModel");
    qmlRegisterType<MenuContentActivator>(uri, 0, 1, "MenuContentActivator");
    qmlRegisterType<UnityMenuModelStack>(uri, 0, 1, "UnityMenuModelStack");
    qmlRegisterType<RootActionState>(uri, 0, 1, "RootActionState");
    qmlRegisterType<ModelPrinter>(uri, 0, 1, "ModelPrinter");
    qmlRegisterType<VisibleIndicatorsModel>(uri, 0, 1, "VisibleIndicatorsModel");
    qmlRegisterType<SharedUnityMenuModel>(uri, 0, 1, "SharedUnityMenuModel");

    qmlRegisterSingletonType<UnityMenuModelCache>(uri, 0, 1, "UnityMenuModelCache", menuModelCacheSingleton);

    qmlRegisterUncreatableType<MenuContentState>(uri, 0, 1, "MenuContentState", "Can't create MenuContentState class");
    qmlRegisterUncreatableType<ActionState>(uri, 0, 1, "ActionState", "Can't create ActionState class");
    qmlRegisterUncreatableType<NetworkActionState>(uri, 0, 1, "NetworkActionState", "Can't create NetworkActionState class");
    qmlRegisterUncreatableType<NetworkConnection>(uri, 0, 1, "NetworkConnection", "Can't create NetworkConnection class");
    qmlRegisterUncreatableType<IndicatorsModelRole>(uri, 0, 1, "IndicatorsModelRole", "Can't create IndicatorsModelRole class");
    qmlRegisterUncreatableType<FlatMenuProxyModelRole>(uri, 0, 1, "FlatMenuProxyModelRole", "Can't create FlatMenuProxyModelRole class");
}
