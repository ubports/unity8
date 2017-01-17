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

#include "mockapplicationmenuregistry.h"

#include <QQmlEngine>
#include <QDebug>

ApplicationMenuRegistry *MockApplicationMenuRegistry::instance()
{
    static ApplicationMenuRegistry* reg(new MockApplicationMenuRegistry(nullptr));
    return reg;
}

MockApplicationMenuRegistry::MockApplicationMenuRegistry(QObject *parent)
    : ApplicationMenuRegistry(parent)
{
}

void MockApplicationMenuRegistry::RegisterSurfaceMenu(const QString &surface,
                                                      const QString &menuObjectPath,
                                                      const QString &actionObjectPath,
                                                      const QString &service)
{
    ApplicationMenuRegistry::RegisterSurfaceMenu(surface,
                                                 QDBusObjectPath(menuObjectPath),
                                                 QDBusObjectPath(actionObjectPath),
                                                 service);
}

void MockApplicationMenuRegistry::UnregisterSurfaceMenu(const QString &surfaceId, const QDBusObjectPath &menuObjectPath)
{
    ApplicationMenuRegistry::UnregisterSurfaceMenu(surfaceId, menuObjectPath);
}
