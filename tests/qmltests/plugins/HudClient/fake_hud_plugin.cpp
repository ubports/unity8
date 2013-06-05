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

#include "fake_hud_plugin.h"

#include "hudclient.h"
#include "volumepeakdetector.h"
#include "libhud_client_stub.h"

#include <deelistmodel.h>

#include <qqml.h>

void FakeHudQmlPlugin::registerTypes(const char *uri)
{
#ifndef GLIB_VERSION_2_36
  g_type_init();
#endif

  qmlRegisterType<QAbstractItemModel>();
  qmlRegisterType<DeeListModel>();

  qmlRegisterType<HudClient>(uri, 0, 1, "HudClient");
  qmlRegisterType<VolumePeakDetector>(uri, 0, 1, "VolumePeakDetector");
  qmlRegisterType<HudClientStub>(uri, 0, 1, "HudClientStub");
}
