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
 *      Nick Dedekind <nick.dedekind@canonical.com>
 */

#ifndef FAKEUNITYMENUMODELCACHE_H
#define FAKEUNITYMENUMODELCACHE_H

#include "unitymenumodelcache.h"

class FakeUnityMenuModelCache : public UnityMenuModelCache
{
    Q_OBJECT
public:
    FakeUnityMenuModelCache(QObject*parent=nullptr);

    Q_INVOKABLE void setCachedModelData(const QByteArray& bus,
                                        const QByteArray& path,
                                        const QVariantMap& actions,
                                        const QVariantMap& properties);
};

#endif // FAKEUNITYMENUMODELCACHE_H
