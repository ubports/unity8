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
 *
 * Author: Nick Dedekind <nick.dedekind@canonical.com>
 */

// Self
#include "fake_unity_plugin.h"

// local
#include "fake_lenses.h"
#include "categories.h"
#include "categoryfilter.h"
#include "fake_launchermodel.h"

// External
#include <glib-object.h>
#include <QtQml>

void FakeUnityPlugin::registerTypes(const char *uri)
{
#ifndef GLIB_VERSION_2_36
  g_type_init();
#endif

    Q_ASSERT(uri == QLatin1String("Unity"));

    qmlRegisterType<Lenses>(uri, 0, 1, "Lenses");
    qmlRegisterType<Lens>(uri, 0, 1, "Lens");
    qmlRegisterType<Categories>(uri, 0, 1, "Categories");
    qmlRegisterType<CategoryFilter>(uri, 0, 1, "CategoryFilter");
    qmlRegisterType<LauncherModel>(uri, 0, 1, "LauncherModel");
    qmlRegisterUncreatableType<LauncherItem>(uri, 0, 1, "LauncherItem", "Can't create");
}
