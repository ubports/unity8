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

#ifndef MOCKAPPLICATIONMENUREGISTRY_H
#define MOCKAPPLICATIONMENUREGISTRY_H

#include <applicationmenuregistry.h>

class MockApplicationMenuRegistry : public ApplicationMenuRegistry
{
    Q_OBJECT
public:

    static ApplicationMenuRegistry* instance();

    Q_INVOKABLE void RegisterSurfaceMenu(const QString &surface,
                                         const QString &menuObjectPath,
                                         const QString &actionObjectPath,
                                         const QString &service);

    Q_INVOKABLE void UnregisterSurfaceMenu(const QString &surfaceId,
                                           const QDBusObjectPath &menuObjectPath);

private:
    MockApplicationMenuRegistry(QObject *parent = 0);
};

#endif // MOCKAPPLICATIONMENUREGISTRY_H
