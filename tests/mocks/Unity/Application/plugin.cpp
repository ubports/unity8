/*
 * Copyright (C) 2013-2016 Canonical, Ltd.
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
#include "ApplicationManager.h"
#include "MirSurfaceItem.h"
#include "SurfaceManager.h"
#include "UbuntuKeyboardInfo.h"

// unity-api
#include <unity/shell/application/Mir.h>

#include <qqml.h>
#include <QQmlEngine>

namespace {

// Creates the singletons that are called throughout C++ code
void createUnityApplicationSharedSingletons()
{
    // they have to be created in a specific order
    if (!MirFocusController::instance()) {
        new MirFocusController;
    }
    if (!SurfaceManager::instance()) {
        new SurfaceManager;
    }
}

QObject* applicationManagerSingleton(QQmlEngine*, QJSEngine*)
{
    createUnityApplicationSharedSingletons();
    return new ApplicationManager;
}

QObject* surfaceManagerSingleton(QQmlEngine*, QJSEngine*)
{
    createUnityApplicationSharedSingletons();
    return SurfaceManager::instance();
}

QObject* ubuntuKeyboardInfoSingleton(QQmlEngine*, QJSEngine*)
{
    createUnityApplicationSharedSingletons();
    return new UbuntuKeyboardInfo;
}

QObject* mirFocusControllerSingleton(QQmlEngine*, QJSEngine*)
{
    createUnityApplicationSharedSingletons();
    return MirFocusController::instance();
}

} // anonymous namespace

void FakeUnityApplicationQmlPlugin::registerTypes(const char *uri)
{
    qRegisterMetaType<ApplicationInfo*>("ApplicationInfo*");
    qRegisterMetaType<unity::shell::application::MirSurfaceInterface*>("unity::shell::application::MirSurfaceInterface*");
    qRegisterMetaType<unity::shell::application::MirSurfaceListInterface*>("unity::shell::application::MirSurfaceListInterface*");
    qRegisterMetaType<Mir::Type>("Mir::Type");
    qRegisterMetaType<Mir::State>("Mir::State");

    qmlRegisterUncreatableType<unity::shell::application::ApplicationManagerInterface>(uri, 0, 1, "ApplicationManagerInterface", "Abstract interface. Cannot be created in QML");
    qmlRegisterUncreatableType<unity::shell::application::ApplicationInfoInterface>(uri, 0, 1, "ApplicationInfoInterface", "Abstract interface. Cannot be created in QML");
    qmlRegisterUncreatableType<MirSurface>(uri, 0, 1, "MirSurface", "MirSurface can't be instantiated from QML");
    qmlRegisterUncreatableType<unity::shell::application::MirSurfaceInterface>(
                    uri, 0, 1, "MirSurface", "MirSurface can't be instantiated from QML");
    qmlRegisterSingletonType<MirFocusController>(uri, 0, 1, "MirFocusController", mirFocusControllerSingleton);
    qmlRegisterType<MirSurfaceItem>(uri, 0, 1, "MirSurfaceItem");
    qmlRegisterType<ApplicationInfo>(uri, 0, 1, "ApplicationInfo");

    qmlRegisterSingletonType<ApplicationManager>(uri, 0, 1, "ApplicationManager", applicationManagerSingleton);
    qmlRegisterSingletonType<SurfaceManager>(uri, 0, 1, "SurfaceManager", surfaceManagerSingleton);
    qmlRegisterSingletonType<UbuntuKeyboardInfo>(uri, 0, 1, "UbuntuKeyboardInfo", ubuntuKeyboardInfoSingleton);

    qmlRegisterUncreatableType<Mir>(uri, 0, 1, "Mir", "Mir provides enum values, it can't be instantiated");
}

void FakeUnityApplicationQmlPlugin::initializeEngine(QQmlEngine *engine, const char *uri)
{
    QQmlExtensionPlugin::initializeEngine(engine, uri);
}
