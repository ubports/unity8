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
 *      Michael Zanetti <michael.zanetti@canonical.com>
 */

#include "plugin.h"
#include "MockLauncherModel.h"
#include "MockLauncherItem.h"
#include "MockQuickListModel.h"
#include "MockAppDrawerModel.h"

#include <unity/shell/launcher/LauncherModelInterface.h>
#include <unity/shell/launcher/LauncherItemInterface.h>
#include <unity/shell/launcher/AppDrawerModelInterface.h>

#include <QtQml/qqml.h>

using namespace unity::shell::launcher;

static QObject* modelProvider(QQmlEngine* /* engine */, QJSEngine* /* scriptEngine */)
{
    return new MockLauncherModel();
}

// cppcheck-suppress unusedFunction
void TestLauncherPlugin::registerTypes(const char* uri)
{
    // @uri Unity.Launcher
    qmlRegisterUncreatableType<LauncherModelInterface>(uri, 0, 1, "LauncherModelInterface", "Abstract Interface. Cannot be instantiated.");
    qmlRegisterUncreatableType<LauncherItemInterface>(uri, 0, 1, "LauncherItemInterface", "Abstract Interface. Cannot be instantiated.");
    qmlRegisterUncreatableType<QuickListModelInterface>(uri, 0, 1, "QuickListModelInterface", "Abstract Interface. Cannot be instantiated.");
    qmlRegisterUncreatableType<AppDrawerModelInterface>(uri, 0, 1, "AppDrawerModelInterface", "Abstract Interface. Cannot be instantiated.");

    qmlRegisterSingletonType<MockLauncherModel>(uri, 0, 1, "LauncherModel", modelProvider);
    qmlRegisterUncreatableType<MockLauncherItem>(uri, 0, 1, "LauncherItem", "Can't create LauncherItems in QML. Get them from the LauncherModel");
    qmlRegisterUncreatableType<MockQuickListModel>(uri, 0, 1, "QuickListModel", "Can't create QuickLists in QML. Get them from the LauncherItems");
    qmlRegisterType<MockAppDrawerModel>(uri, 0, 1, "AppDrawerModel");
}
