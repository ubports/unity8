/*
 * Copyright (C) 2012 Canonical, Ltd.
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
 * Author: Michał Sawicz <michal.sawicz@canonical.com>
 */

// Qt
#include <QtQml/qqml.h>
#include <QDBusConnection>
#include <QQmlContext>
#include <QtQuick/QQuickWindow>
#include <QDebug>
// self
#include "plugin.h"

// local
#include "bottombarvisibilitycommunicatorshell.h"
#include "qlimitproxymodelqml.h"
#include "qsortfilterproxymodelqml.h"
#include "timeformatter.h"
#include "unitymenumodelpaths.h"
#include "easingcurve.h"

static const char* BOTTOM_BAR_VISIBILITY_COMMUNICATOR_DBUS_PATH = "/BottomBarVisibilityCommunicator";
static const char* DBUS_SERVICE = "com.canonical.Shell.BottomBarVisibilityCommunicator";

void UtilsPlugin::registerTypes(const char *uri)
{
    Q_ASSERT(uri == QLatin1String("Utils"));
    qmlRegisterType<QAbstractItemModel>();
    qmlRegisterType<QLimitProxyModelQML>(uri, 0, 1, "LimitProxyModel");
    qmlRegisterType<QSortFilterProxyModelQML>(uri, 0, 1, "SortFilterProxyModel");
    qmlRegisterType<UnityMenuModelPaths>(uri, 0, 1, "UnityMenuModelPaths");
    qmlRegisterType<TimeFormatter>(uri, 0, 1, "TimeFormatter");
    qmlRegisterType<GDateTimeFormatter>(uri, 0, 1, "GDateTimeFormatter");
    qmlRegisterUncreatableType<BottomBarVisibilityCommunicatorShell>(uri, 0, 1, "BottomBarVisibilityCommunicatorShell", "Can't create BottomBarVisibilityCommunicatorShell");
    qmlRegisterType<EasingCurve>(uri, 0, 1, "EasingCurve");
}

void UtilsPlugin::initializeEngine(QQmlEngine *engine, const char *uri)
{
    QQmlExtensionPlugin::initializeEngine(engine, uri);

    QDBusConnection::sessionBus().registerService(DBUS_SERVICE);
    BottomBarVisibilityCommunicatorShell *bottomBarVisibilityCommunicator = &BottomBarVisibilityCommunicatorShell::instance();
    QDBusConnection::sessionBus().registerObject(BOTTOM_BAR_VISIBILITY_COMMUNICATOR_DBUS_PATH, bottomBarVisibilityCommunicator, QDBusConnection::ExportAllContents);
    engine->rootContext()->setContextProperty("bottomBarVisibilityCommunicatorShell", bottomBarVisibilityCommunicator);
}
