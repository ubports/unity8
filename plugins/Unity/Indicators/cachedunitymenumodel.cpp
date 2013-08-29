/*
 * Copyright (C) 2012, 2013 Canonical, Ltd.
 *
 * This program is free software; you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation; version 3.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.
 *
 * Authors:
 *      Nick Dedekind <nick.dedekind@canonical.com>
 */

// self
#include "cachedunitymenumodel.h"
#include "unitymenumodelcache.h"

#include <unitymenumodel.h>

CachedUnityMenuModel::CachedUnityMenuModel(QObject* parent)
    : QObject(parent),
      m_model(NULL)
{
}

CachedUnityMenuModel::~CachedUnityMenuModel()
{
    // deref old model.
    if (m_model) {
        UnityMenuModelCache::cache()->deref(m_menuObjectPath);
        m_model = NULL;
    }
}

UnityMenuModel* CachedUnityMenuModel::model() const
{
    return m_model;
}

QString CachedUnityMenuModel::busName() const
{
    return m_busName;
}

void CachedUnityMenuModel::setBusName(const QString &name)
{
    if (m_busName != name) {
        m_busName = name;
        Q_EMIT busNameChanged(m_busName);

        if (m_model && m_model->busName() != m_busName) {
            m_model->setBusName(m_busName.toUtf8());
        }
    }
}

QVariantMap CachedUnityMenuModel::actions() const
{
    return m_model->actions();
}

void CachedUnityMenuModel::setActions(const QVariantMap &actions)
{
    if (m_actions != actions) {
        m_actions = actions;
        Q_EMIT actionsChanged(m_actions);

        if (m_model && m_model->actions() != m_actions) {
            m_model->setActions(m_actions);
        }
    }
}

QString CachedUnityMenuModel::menuObjectPath() const
{
    return m_model->menuObjectPath();
}

void CachedUnityMenuModel::setMenuObjectPath(const QString &path)
{
    if (m_menuObjectPath != path) {
        // deref old model.
        if (m_model) {
            UnityMenuModelCache::cache()->deref(m_menuObjectPath);
            m_model = NULL;
        }

        m_menuObjectPath = path;
        Q_EMIT menuObjectPathChanged(m_menuObjectPath);

        // create new model.
        if (!m_menuObjectPath.isEmpty()) {
            m_model = UnityMenuModelCache::cache()->model(m_menuObjectPath);
            if (!m_model) {
                m_model = new UnityMenuModel;
                if (!m_busName.isEmpty()) m_model->setBusName(m_busName.toUtf8());
                if (!m_actions.isEmpty()) m_model->setActions(m_actions);
                m_model->setMenuObjectPath(m_menuObjectPath.toUtf8());

                UnityMenuModelCache::cache()->registerModel(m_menuObjectPath, m_model);
            }
            UnityMenuModelCache::cache()->ref(m_menuObjectPath);
        }

        Q_EMIT modelChanged(m_model);
    }
}
