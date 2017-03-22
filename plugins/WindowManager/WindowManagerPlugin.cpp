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

#include "Screen.h"
#include "ScreenAttached.h"
#include "Screens.h"
#include "ScreenWindow.h"
#include "TopLevelWindowModel.h"
#include "Window.h"
#include "WindowManagerObjects.h"
#include "WorkspaceManager.h"
#include "Workspace.h"
#include "WorkspaceModel.h"

#include <QtQml>
#include <qtmir/qtmir.h>

namespace {

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

} // namspace

void WindowManagerPlugin::registerTypes(const char *uri)
{
    qmlRegisterSingletonType<WorkspaceManager>(uri, 1, 0, "WorkspaceManager", workspace_manager);
    qmlRegisterUncreatableType<WorkspaceModel>(uri, 1, 0, "WorkspaceModel", notInstantiatable);
    qmlRegisterSingletonType<ConcreteScreens>(uri, 1, 0, "Screens", screensSingleton);
    qmlRegisterUncreatableType<qtmir::ScreenMode>(uri, 1, 0, "ScreenMode", notInstantiatable);
    qmlRegisterSingletonType<WindowManagerObjects>(uri, 1, 0, "WindowManagerObjects", objectsSingleton);

    qRegisterMetaType<ConcreteScreen*>("ConcreteScreen*");
    qRegisterMetaType<ProxyScreens*>("ProxyScreens*");
    qRegisterMetaType<Workspace*>("Workspace*");
    qRegisterMetaType<TopLevelWindowModel*>("TopLevelWindowModel*");

    qRegisterMetaType<Window*>("Window*");
    qRegisterMetaType<QAbstractListModel*>("QAbstractListModel*");

    qmlRegisterType<ScreenWindow>(uri, 1, 0, "ScreenWindow");
    qmlRegisterRevision<QWindow,1>(uri, 1, 0);

    qmlRegisterUncreatableType<WMScreen>(uri, 1, 0, "WMScreen", notInstantiatable);
}

void WindowManagerPlugin::initializeEngine(QQmlEngine *engine, const char *uri)
{
    WindowManagerPlugin::initializeEngine(engine, uri);

    // Create Screens
    new ConcreteScreens(qtmir::get_screen_model());
}
