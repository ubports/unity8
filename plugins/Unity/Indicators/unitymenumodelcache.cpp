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

#include "unitymenumodelcache.h"
#include <unitymenumodel.h>

#include <QQmlEngine>

QPointer<UnityMenuModelCache> UnityMenuModelCache::theCache = nullptr;

UnityMenuModelCache* UnityMenuModelCache::singleton()
{
    if (theCache.isNull()) {
        theCache = new UnityMenuModelCache();
    }
    return theCache.data();
}

UnityMenuModelCache::UnityMenuModelCache(QObject* parent)
    : QObject(parent)
{
}

QSharedPointer<UnityMenuModel> UnityMenuModelCache::model(const QByteArray& path)
{
    if (m_registry.contains(path))
        return m_registry[path];

    UnityMenuModel* model = new UnityMenuModel;
    QQmlEngine::setObjectOwnership(model, QQmlEngine::CppOwnership);

    QSharedPointer<UnityMenuModel> menuModel(model);
    connect(model, &QObject::destroyed, this, [this] {
        QMutableHashIterator<QByteArray, QWeakPointer<UnityMenuModel>> iter(m_registry);
        while(iter.hasNext()) {
            auto keyVal = iter.next();
            if (keyVal.value().isNull()) {
                iter.remove();
                break;
            }
        }
    });
    m_registry[path] = menuModel.toWeakRef();

    menuModel->setMenuObjectPath(path);
    return menuModel;
}

bool UnityMenuModelCache::contains(const QByteArray& path)
{
    return m_registry.contains(path);
}
