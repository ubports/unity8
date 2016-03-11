/*
 * Copyright (C) 2015 Canonical, Ltd.
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

// Qt
#include <QtQml/qqml.h>
#include <QDBusConnection>
#include <QQmlContext>
#include <QtQuick/QQuickWindow>
#include <QDebug>

// local
#include "plugin.h"
#include "windowstatestorage.h"
#include "constants.h"

// plugin
#include <activefocuslogger.h>
#include <inputwatcher.h>
#include <qlimitproxymodelqml.h>
#include <unitysortfilterproxymodelqml.h>
#include <unitymenumodelpaths.h>
#include <windowkeysfilter.h>
#include <windowscreenshotprovider.h>
#include <easingcurve.h>
#include <timezoneFormatter.h>
#include <applicationsfiltermodel.h>
#include <inputeventgenerator.h>
#include <deviceconfigparser.h>
#include <globalfunctions.h>

static QObject *createWindowStateStorage(QQmlEngine *engine, QJSEngine *scriptEngine)
{
    Q_UNUSED(engine)
    Q_UNUSED(scriptEngine)
    return new WindowStateStorage();
}

static QObject *createConstants(QQmlEngine *engine, QJSEngine *scriptEngine)
{
    Q_UNUSED(engine)
    Q_UNUSED(scriptEngine)
    return new Constants();
}

static QObject *createGlobalFunctions(QQmlEngine *engine, QJSEngine *scriptEngine)
{
    Q_UNUSED(engine)
    Q_UNUSED(scriptEngine)
    return new GlobalFunctions();
}

void FakeUtilsPlugin::registerTypes(const char *uri)
{
    Q_ASSERT(uri == QLatin1String("Utils"));
    qmlRegisterType<QAbstractItemModel>();
    qmlRegisterType<QLimitProxyModelQML>(uri, 0, 1, "LimitProxyModel");
    qmlRegisterType<UnitySortFilterProxyModelQML>(uri, 0, 1, "UnitySortFilterProxyModel");
    qmlRegisterType<UnityMenuModelPaths>(uri, 0, 1, "UnityMenuModelPaths");
    qmlRegisterType<WindowKeysFilter>(uri, 0, 1, "WindowKeysFilter");
    qmlRegisterType<EasingCurve>(uri, 0, 1, "EasingCurve");
    qmlRegisterSingletonType<WindowStateStorage>(uri, 0, 1, "WindowStateStorage", createWindowStateStorage);
    qmlRegisterType<InputWatcher>(uri, 0, 1, "InputWatcher");
    qmlRegisterSingletonType<Constants>(uri, 0, 1, "Constants", createConstants);
    qmlRegisterSingletonType<TimezoneFormatter>(uri, 0, 1, "TimezoneFormatter",
                                                [](QQmlEngine*, QJSEngine*) -> QObject* { return new TimezoneFormatter; });
    qmlRegisterType<ActiveFocusLogger>(uri, 0, 1, "ActiveFocusLogger");
    qmlRegisterType<ApplicationsFilterModel>(uri, 0, 1, "ApplicationsFilterModel");
    qmlRegisterType<InputEventGenerator>(uri, 0, 1, "InputEventGenerator");
    qmlRegisterType<DeviceConfigParser>(uri, 0, 1, "DeviceConfigParser");
    qmlRegisterSingletonType<GlobalFunctions>(uri, 0, 1, "Functions", createGlobalFunctions);
}

void FakeUtilsPlugin::initializeEngine(QQmlEngine *engine, const char *uri)
{
    QQmlExtensionPlugin::initializeEngine(engine, uri);

    engine->addImageProvider(QLatin1String("window"), new WindowScreenshotProvider);
}
