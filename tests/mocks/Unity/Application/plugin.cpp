/*
 * Copyright (C) 2013-2014 Canonical, Ltd.
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
#include "ApplicationManager.h"
#include "ApplicationScreenshotProvider.h"
#include "MirSurfaceItem.h"
#include "MirSurfaceItemModel.h"
#include "SurfaceManager.h"
#include "ApplicationTestInterface.h"

#include <qqml.h>
#include <QQmlEngine>

static QObject* applicationManagerSingleton(QQmlEngine* engine, QJSEngine* scriptEngine) {
    Q_UNUSED(engine);
    Q_UNUSED(scriptEngine);
    return ApplicationManager::singleton();
}

static QObject* surfaceManagerSingleton(QQmlEngine* engine, QJSEngine* scriptEngine) {
    Q_UNUSED(engine);
    Q_UNUSED(scriptEngine);
    return SurfaceManager::singleton();
}

ApplicationTestInterface* s_appTestInterface = nullptr;

static QObject* applicationTestInterface(QQmlEngine* engine, QJSEngine* scriptEngine) {
    Q_UNUSED(engine);
    Q_UNUSED(scriptEngine);
    if (!s_appTestInterface) {
        s_appTestInterface = new ApplicationTestInterface(engine);
    }
    return s_appTestInterface;
}

void FakeUnityApplicationQmlPlugin::registerTypes(const char *uri)
{
    qRegisterMetaType<MirSurfaceItem*>("MirSurfaceItem*");
    qRegisterMetaType<MirSurfaceItemModel*>("MirSurfaceItemModel*");

    qmlRegisterUncreatableType<unity::shell::application::ApplicationManagerInterface>(uri, 0, 1, "ApplicationManagerInterface", "Abstract interface. Cannot be created in QML");
    qmlRegisterUncreatableType<unity::shell::application::ApplicationInfoInterface>(uri, 0, 1, "ApplicationInfoInterface", "Abstract interface. Cannot be created in QML");
    qmlRegisterUncreatableType<MirSurfaceItem>(uri, 0, 1, "MirSurfaceItem", "MirSurfaceItem can't be instantiated from QML");

    qmlRegisterType<ApplicationInfo>(uri, 0, 1, "ApplicationInfo");
    qmlRegisterType<ApplicationImage>(uri, 0, 1, "ApplicationImage");

    qmlRegisterSingletonType<ApplicationManager>(uri, 0, 1, "ApplicationManager", applicationManagerSingleton);
    qmlRegisterSingletonType<SurfaceManager>(uri, 0, 1, "SurfaceManager", surfaceManagerSingleton);
    qmlRegisterSingletonType<ApplicationTestInterface>(uri, 0, 1, "ApplicationTest", applicationTestInterface);
}

void FakeUnityApplicationQmlPlugin::initializeEngine(QQmlEngine *engine, const char *uri)
{
    QQmlExtensionPlugin::initializeEngine(engine, uri);

    engine->addImageProvider(QLatin1String("application"), new ApplicationScreenshotProvider(ApplicationManager::singleton()));
    // make sure we initialise our test interface.
    applicationTestInterface(engine, nullptr);
}
