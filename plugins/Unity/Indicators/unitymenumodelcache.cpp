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


UnityMenuModel* UnityMenuModelCache::model(const QString& path) const
{
    return m_menuModels.value(path, NULL);
}

void UnityMenuModelCache::registerModel(const QString& path, UnityMenuModel* menuModel)
{
    menuModel->setParent(this);
    m_menuModels[path] = menuModel;
}

UnityMenuModelCache* UnityMenuModelCache::cache()
{
    static UnityMenuModelCache* model = new UnityMenuModelCache;
    return model;
}

void UnityMenuModelCache::ref(const QString& path)
{
    if (!m_refs.contains(path)) {
        m_refs[path] = 1;
    } else {
        m_refs[path]++;
    }
}

bool UnityMenuModelCache::deref(const QString& path)
{
    if (m_refs.contains(path)) {
        if (--m_refs[path] <= 0) {
            delete m_menuModels.value(path, NULL);
            m_menuModels.remove(path);
            m_refs.remove(path);
            return false;
        }
    }
    return true;
}
