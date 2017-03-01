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

#include "Screens.h"
#include "Screen.h"
#include "MockScreens.h"
#include "ScreenWindow.h"
#include "TopLevelWindowModel.h"
#include "Window.h"
#include "WorkspaceManager.h"
#include "Workspace.h"
#include "WorkspaceModel.h"

#include <QtQml>

static QObject *workspace_manager(QQmlEngine *engine, QJSEngine *scriptEngine)
{
    Q_UNUSED(engine)
    Q_UNUSED(scriptEngine)
    return WorkspaceManager::instance();
}
QObject* screensSingleton(QQmlEngine* engine, QJSEngine* scriptEngine) {
    Q_UNUSED(engine);
    Q_UNUSED(scriptEngine);
    QSharedPointer<qtmir::Screens> mockScreens(new MockScreens());
    return new Screens(mockScreens);
}

void WindowManagerPlugin::registerTypes(const char *uri)
{
    qmlRegisterType<TopLevelWindowModel>(uri, 1, 0, "TopLevelWindowModel");
    qmlRegisterSingletonType<WorkspaceManager>(uri, 1, 0, "WorkspaceManager", workspace_manager);
    qmlRegisterUncreatableType<WorkspaceModel>(uri, 1, 0, "WorkspaceModel", "Not a creatable type");
    qmlRegisterSingletonType<Screens>(uri, 1, 0, "Screens", screensSingleton);
    qmlRegisterUncreatableType<qtmir::ScreenMode>(uri, 1, 0, "ScreenMode", "ScreenMode is not creatable.");
    qmlRegisterUncreatableType<Workspace>(uri, 1, 0, "Workspace", "Workspace is not creatable.");

    qRegisterMetaType<Screen*>("Screen*");
    qRegisterMetaType<ScreensProxy*>("ScreensProxy*");
    qRegisterMetaType<Workspace*>("Workspace*");

    qRegisterMetaType<Window*>("Window*");
    qRegisterMetaType<QAbstractListModel*>("QAbstractListModel*");

    qmlRegisterType<ScreenWindow>(uri, 1, 0, "ScreenWindow");
    qmlRegisterRevision<QWindow,1>(uri, 1, 0);
}
