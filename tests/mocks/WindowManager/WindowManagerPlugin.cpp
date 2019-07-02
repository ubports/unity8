/*
 * Copyright (C) 2016 Canonical, Ltd.
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

#include "WindowManagerPlugin.h"

#include "AvailableDesktopArea.h"
#include "MockScreens.h"
#include "MockScreenWindow.h"
#include "Screen.h"
#include "ScreenAttached.h"
#include "Screens.h"
#include "ScreensConfiguration.h"
#include "TopLevelWindowModel.h"
#include "Window.h"
#include "WindowMargins.h"
#include "WindowManagementPolicy.h"
#include "WindowManagerObjects.h"
#include "WorkspaceManager.h"
#include "Workspace.h"
#include "WorkspaceModel.h"

#include <QtQml>

static const QString notInstantiatable = QStringLiteral("Not instantiatable");

static QObject *workspace_manager(QQmlEngine *engine, QJSEngine *scriptEngine)
{
    Q_UNUSED(engine)
    Q_UNUSED(scriptEngine)
    return WorkspaceManager::instance();
}
QObject* screensSingleton(QQmlEngine* engine, QJSEngine* scriptEngine) {
    Q_UNUSED(engine);
    Q_UNUSED(scriptEngine);
    return ConcreteScreens::self();
}
QObject* objectsSingleton(QQmlEngine* engine, QJSEngine* scriptEngine) {
    Q_UNUSED(engine);
    Q_UNUSED(scriptEngine);
    return WindowManagerObjects::instance();
}

void WindowManagerPlugin::registerTypes(const char *uri)
{
    qmlRegisterType<AvailableDesktopArea>(uri, 1, 0, "AvailableDesktopArea");
    qmlRegisterType<WindowMargins>(uri, 1, 0, "WindowMargins");
    qmlRegisterSingletonType<WorkspaceManager>(uri, 1, 0, "WorkspaceManager", workspace_manager);
    qmlRegisterSingletonType<ConcreteScreens>(uri, 1, 0, "Screens", screensSingleton);
    qmlRegisterUncreatableType<qtmir::ScreenMode>(uri, 1, 0, "ScreenMode", notInstantiatable);
    qmlRegisterSingletonType<WindowManagerObjects>(uri, 1, 0, "WindowManagerObjects", objectsSingleton);

    qRegisterMetaType<ConcreteScreen*>("ConcreteScreen*");
    qRegisterMetaType<ProxyScreens*>("ProxyScreens*");
    qRegisterMetaType<Workspace*>("Workspace*");
    qRegisterMetaType<TopLevelWindowModel*>("TopLevelWindowModel*");
    qRegisterMetaType<ScreenConfig*>("ScreenConfig*");
    qRegisterMetaType<WorkspaceModel*>("WorkspaceModel*");

    qRegisterMetaType<Window*>("Window*");
    qRegisterMetaType<QAbstractListModel*>("QAbstractListModel*");

    qmlRegisterType<MockScreenWindow>(uri, 1, 0, "ScreenWindow");
    qmlRegisterRevision<QWindow,1>(uri, 1, 0);

    qmlRegisterUncreatableType<WMScreen>(uri, 1, 0, "WMScreen", notInstantiatable);
}

void WindowManagerPlugin::initializeEngine(QQmlEngine *engine, const char *uri)
{
    QQmlExtensionPlugin::initializeEngine(engine, uri);

    // Make sure we've initialized the wm policy.
    WindowManagementPolicy::instance();
    // Create Screens
    new ConcreteScreens(MockScreens::instance(), new ScreensConfiguration());
}
