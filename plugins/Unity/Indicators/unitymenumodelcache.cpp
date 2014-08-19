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

UnityMenuModelCache::UnityMenuModelCache(QObject* parent)
    : QObject(parent)
{
}

UnityMenuModelCache::~UnityMenuModelCache()
{
    qDeleteAll(m_menuModels);
}

UnityMenuModel* UnityMenuModelCache::model(const QString& path) const
{
    return m_menuModels.value(path, NULL);
}

void UnityMenuModelCache::registerModel(const QString& path, UnityMenuModel* menuModel)
{
    QQmlEngine::setObjectOwnership(menuModel, QQmlEngine::CppOwnership);
    menuModel->setParent(this);
    m_menuModels[path] = menuModel;
}

void UnityMenuModelCache::ref(UnityMenuModel* menuModel)
{
    m_refs[menuModel] = m_refs.value(menuModel, 0) + 1;
}

void UnityMenuModelCache::deref(UnityMenuModel* menuModel)
{
    if (m_refs.contains(menuModel)) {
        if (m_refs[menuModel]-- == 0) {
            m_refs.remove(menuModel);
            QList<QString> keys = m_menuModels.keys(menuModel);
            Q_FOREACH(const QString& key, keys) {
                m_menuModels.remove(key);
            }
            delete menuModel;
        }
    }
}
