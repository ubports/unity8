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

#include "fakeunitymenumodelcache.h"
#include <unitymenumodel.h>

FakeUnityMenuModelCache* FakeUnityMenuModelCache::theFakeCache = nullptr;

FakeUnityMenuModelCache* FakeUnityMenuModelCache::singleton()
{
    if (!theFakeCache) {
        theFakeCache = new FakeUnityMenuModelCache();
    }
    return theFakeCache;
}

FakeUnityMenuModelCache::FakeUnityMenuModelCache(QObject* parent)
    : UnityMenuModelCache(parent)
{
}

QSharedPointer<UnityMenuModel> FakeUnityMenuModelCache::model(const QByteArray& bus,
                                                              const QByteArray& path,
                                                              const QVariantMap& actions)
{
    return UnityMenuModelCache::singleton()->model(bus, path, actions);
}

bool FakeUnityMenuModelCache::contains(const QByteArray& path)
{
    return UnityMenuModelCache::singleton()->contains(path);
}

void FakeUnityMenuModelCache::setCachedModelData(const QByteArray& bus,
                                                 const QByteArray& path,
                                                 const QVariantMap& actions,
                                                 const QVariantMap& properties,
                                                 const QVariant& data)
{
    // keep a ref forever!
    if (!m_models.contains(path)) {
        m_models[path] = model(bus, path, actions);
    }
    m_models[path]->setRootProperties(properties);
    m_models[path]->setModelData(data);
}
