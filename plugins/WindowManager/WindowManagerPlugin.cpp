/*
 * Copyright (C) 2016-2017 Canonical, Ltd.
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
#include "TopLevelWindowModel.h"
#include "Window.h"
#include "WindowMargins.h"

#include <QtQml>

void WindowManagerPlugin::registerTypes(const char *uri)
{
    qmlRegisterType<AvailableDesktopArea>(uri, 1, 0, "AvailableDesktopArea");
    qmlRegisterType<TopLevelWindowModel>(uri, 1, 0, "TopLevelWindowModel");
    qmlRegisterType<WindowMargins>(uri, 1, 0, "WindowMargins");

    qRegisterMetaType<Window*>("Window*");

    qRegisterMetaType<QAbstractListModel*>("QAbstractListModel*");
}
