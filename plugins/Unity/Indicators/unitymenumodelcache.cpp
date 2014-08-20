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

UnityMenuModelCache::UnityMenuModelCache(QObject* parent)
    : QObject(parent)
{
}

UnityMenuModelCache::~UnityMenuModelCache()
{
}

UnityMenuModel* UnityMenuModelCache::model(const QByteArray& bus,
                                           const QByteArray& path,
                                           const QVariantMap& actions)
{
    if (m_registry.contains(path))
        return m_registry[path];

    UnityMenuModel* menuModel = new UnityMenuModel;
    connect(menuModel, &QObject::destroyed, this, [menuModel, this](QObject*) {
        QList<QByteArray> keys = m_registry.keys(menuModel);
        Q_FOREACH(const QByteArray& key, keys) {
            m_registry.remove(key);
        }
    });
    m_registry[path] = menuModel;

    menuModel->setBusName(bus);
    menuModel->setMenuObjectPath(path);
    menuModel->setActions(actions);
    return menuModel;
}

bool UnityMenuModelCache::contains(UnityMenuModel* menuModel)
{
    return !m_registry.keys(menuModel).isEmpty();
}
