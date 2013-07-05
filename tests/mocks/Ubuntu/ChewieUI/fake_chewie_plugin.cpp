/*
 * Copyright (C) 2012, 2013 Canonical, Ltd.
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

#include "fake_chewie_plugin.h"
#include "fake_pluginmodel.h"

#include <qqml.h>

void FakeChewieQmlPlugin::registerTypes(const char *uri)
{
// #ifndef GLIB_VERSION_2_36
//   g_type_init();
// #endif

  qmlRegisterUncreatableType<WidgetsMap>(uri, 0, 1, "WidgetsMap", "WidgetsMap must be created by PluginModel");
  qmlRegisterType<PluginModel>(uri, 0, 1, "PluginModel");
}
