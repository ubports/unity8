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

#include "fakelomirimenumodelcache.h"
#include <unitymenumodel.h>

QPointer<FakeLomiriMenuModelCache> FakeLomiriMenuModelCache::theFakeCache = nullptr;

FakeLomiriMenuModelCache* FakeLomiriMenuModelCache::singleton()
{
    if (theFakeCache.isNull()) {
        theFakeCache = new FakeLomiriMenuModelCache();
    }
    return theFakeCache.data();
}

FakeLomiriMenuModelCache::FakeLomiriMenuModelCache(QObject* parent)
    : LomiriMenuModelCache(parent)
{
}

QSharedPointer<UnityMenuModel> FakeLomiriMenuModelCache::model(const QByteArray& path)
{
    return LomiriMenuModelCache::singleton()->model(path);
}

bool FakeLomiriMenuModelCache::contains(const QByteArray& path)
{
    return LomiriMenuModelCache::singleton()->contains(path);
}

void FakeLomiriMenuModelCache::setCachedModelData(const QByteArray& path,
                                                 const QVariant& data)
{
    // keep a ref forever!
    if (!m_models.contains(path)) {
        m_models[path] = model(path);
    }
    m_models[path]->setModelData(data);
}

QVariant FakeLomiriMenuModelCache::getCachedModelData(const QByteArray& path)
{
    QSharedPointer<UnityMenuModel> model = this->model(path);
    return model.isNull() ? QVariant() : model->modelData();
}
