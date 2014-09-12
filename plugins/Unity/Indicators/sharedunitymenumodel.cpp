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
 *
 */

#include "sharedunitymenumodel.h"
#include "unitymenumodelcache.h"

SharedUnityMenuModel::SharedUnityMenuModel(QObject* parent)
    : QObject(parent)
{
}

QByteArray SharedUnityMenuModel::busName() const
{
    return m_busName;
}

void SharedUnityMenuModel::setBusName(const QByteArray& busName)
{
    if (m_busName != busName) {
        m_busName = busName;
        Q_EMIT busNameChanged();
        initialize();
    }
}

QByteArray SharedUnityMenuModel::menuObjectPath() const
{
    return m_menuObjectPath;
}

void SharedUnityMenuModel::setMenuObjectPath(const QByteArray& menuObjectPath)
{
    if (m_menuObjectPath != menuObjectPath) {
        m_menuObjectPath = menuObjectPath;
        Q_EMIT menuObjectPathChanged();
        initialize();
    }
}

QVariantMap SharedUnityMenuModel::actions() const
{
    return m_actions;
}

void SharedUnityMenuModel::setActions(const QVariantMap& actions)
{
    if (m_actions != actions) {
        m_actions = actions;
        Q_EMIT actionsChanged();
        initialize();
    }
}

UnityMenuModel* SharedUnityMenuModel::model() const
{
    return m_model ? m_model.data() : nullptr;
}

void SharedUnityMenuModel::initialize()
{
    if (m_busName.isEmpty() || m_menuObjectPath.isEmpty() || m_actions.isEmpty()) {
        if (!m_model.isNull()) {
            m_model.clear();
            Q_EMIT modelChanged();
        }
    } else {
        QSharedPointer<UnityMenuModel> model = UnityMenuModelCache::singleton()->model(m_busName, m_menuObjectPath, m_actions);
        if (model != m_model) {
            m_model = model;
            Q_EMIT modelChanged();
        }
    }
}
