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
#include "ApplicationManager.h"
#include "ApplicationScreenshotProvider.h"
#include "MirSurfaceItem.h"
#include "SurfaceManager.h"

#include <qqml.h>
#include <QQmlEngine>

ApplicationManager *s_appManager = 0;

static QObject* applicationManagerSingleton(QQmlEngine* engine, QJSEngine* scriptEngine) {
    Q_UNUSED(engine);
    Q_UNUSED(scriptEngine);
    if (!s_appManager) {
        s_appManager = new ApplicationManager();
    }
    return s_appManager;
}

static QObject* surfaceManagerSingleton(QQmlEngine* engine, QJSEngine* scriptEngine) {
    Q_UNUSED(engine);
    Q_UNUSED(scriptEngine);
    return SurfaceManager::singleton();
}

void FakeUnityApplicationQmlPlugin::registerTypes(const char *uri)
{
    qRegisterMetaType<MirSurfaceItem*>("MirSurfaceItem*");

    qmlRegisterUncreatableType<unity::shell::application::ApplicationManagerInterface>(uri, 0, 1, "ApplicationManagerInterface", "Abstract interface. Cannot be created in QML");
    qmlRegisterSingletonType<ApplicationManager>(uri, 0, 1, "ApplicationManager", applicationManagerSingleton);
    qmlRegisterSingletonType<SurfaceManager>(uri, 0, 1, "SurfaceManager", surfaceManagerSingleton);

    qmlRegisterUncreatableType<unity::shell::application::ApplicationInfoInterface>(uri, 0, 1, "ApplicationInfoInterface", "Abstract interface. Cannot be created in QML");
    qmlRegisterType<ApplicationInfo>(uri, 0, 1, "ApplicationInfo");

    qmlRegisterUncreatableType<MirSurfaceItem>(uri, 0, 1, "MirSurfaceItem", "MirSurfaceItem can't be instantiated from QML");

    qmlRegisterType<ApplicationImage>(uri, 0, 1, "ApplicationImage");
}

void FakeUnityApplicationQmlPlugin::initializeEngine(QQmlEngine *engine, const char *uri)
{
    QQmlExtensionPlugin::initializeEngine(engine, uri);

    ApplicationManager* appManager = static_cast<ApplicationManager*>(applicationManagerSingleton(engine, NULL));
    engine->addImageProvider(QLatin1String("application"), new ApplicationScreenshotProvider(appManager));
}
