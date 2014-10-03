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

    // Parent the model to us, so it is not deleted by Qml.  We want to keep
    // all models cached, because when we switch indicator profiles, we will
    // be switching paths often.  And we want to keep the old model around,
    // ready to be used.  Otherwise the UI might momentarily wait as we
    // populate the model from DBus yet again.
    UnityMenuModel* menuModel = new UnityMenuModel(this);
    m_registry[path] = menuModel;

    menuModel->setBusName(bus);
    menuModel->setMenuObjectPath(path);
    menuModel->setActions(actions);
    return menuModel;
}

bool UnityMenuModelCache::contains(const QByteArray& path)
{
    return m_registry.contains(path);
}
