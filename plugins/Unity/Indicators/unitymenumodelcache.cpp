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

    // Keep a shared pointer (rather than weak pointer which would cause the
    // model to be deleted when all shared pointers we give out are deleted).
    // We want to keep all models cached because when we switch indicator
    // profiles, we will be switching paths often.  And we want to keep the
    // old model around, ready to be used.  Otherwise the UI might momentarily
    // wait as we populate the model from DBus yet again.
    m_registry[path] = menuModel;

    menuModel->setMenuObjectPath(path);
    return menuModel;
}

bool UnityMenuModelCache::contains(const QByteArray& path)
{
    return m_registry.contains(path);
}
