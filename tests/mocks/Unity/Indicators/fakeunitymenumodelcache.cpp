/*
 * Copyright 2014 Canonical Ltd.
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
 */

#include "fakeunitymenumodelcache.h"
#include <unitymenumodel.h>

QPointer<FakeUnityMenuModelCache> FakeUnityMenuModelCache::theFakeCache = nullptr;

FakeUnityMenuModelCache* FakeUnityMenuModelCache::singleton()
{
    if (theFakeCache.isNull()) {
        theFakeCache = new FakeUnityMenuModelCache();
    }
    return theFakeCache.data();
}

FakeUnityMenuModelCache::FakeUnityMenuModelCache(QObject* parent)
    : UnityMenuModelCache(parent)
{
}

QSharedPointer<UnityMenuModel> FakeUnityMenuModelCache::model(const QByteArray& path)
{
    return UnityMenuModelCache::singleton()->model(path);
}

bool FakeUnityMenuModelCache::contains(const QByteArray& path)
{
    return UnityMenuModelCache::singleton()->contains(path);
}

void FakeUnityMenuModelCache::setCachedModelData(const QByteArray& path,
                                                 const QVariant& data)
{
    // keep a ref forever!
    if (!m_models.contains(path)) {
        m_models[path] = model(path);
    }
    m_models[path]->setModelData(data);
}

QVariant FakeUnityMenuModelCache::getCachedModelData(const QByteArray& path)
{
    QSharedPointer<UnityMenuModel> model = this->model(path);
    return model.isNull() ? QVariant() : model->modelData();
}
