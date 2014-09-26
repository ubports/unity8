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
#include <QDebug>

UnityMenuModelCache* FakeUnityMenuModelCache::singleton()
{
    if (!theCache) {
        theCache = new UnityMenuModelCache();
    }
    return theCache;
}

FakeUnityMenuModelCache::FakeUnityMenuModelCache(QObject* parent)
    : UnityMenuModelCache(parent)
{
}

void FakeUnityMenuModelCache::setCachedModelData(const QByteArray& bus,
                                                 const QByteArray& path,
                                                 const QVariantMap& actions,
                                                 const QVariantMap& properties)
{
    // keep a ref forever!
    if (!m_models.contains(path)) {
        m_models[path] = model(bus, path, actions);
    }
    m_models[path]->setRootProperties(properties);
}
