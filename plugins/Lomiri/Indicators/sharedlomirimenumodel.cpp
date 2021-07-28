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

#include "sharedlomirimenumodel.h"
#include "lomirimenumodelcache.h"

#include <unitymenumodel.h>

SharedLomiriMenuModel::SharedLomiriMenuModel(QObject* parent)
    : QObject(parent)
{
}

QByteArray SharedLomiriMenuModel::busName() const
{
    return m_busName;
}

void SharedLomiriMenuModel::setBusName(const QByteArray& busName)
{
    if (m_busName != busName) {
        m_busName = busName;
        Q_EMIT busNameChanged();
        initialize();
    }
}

QByteArray SharedLomiriMenuModel::menuObjectPath() const
{
    return m_menuObjectPath;
}

void SharedLomiriMenuModel::setMenuObjectPath(const QByteArray& menuObjectPath)
{
    if (m_menuObjectPath != menuObjectPath) {
        m_menuObjectPath = menuObjectPath;
        Q_EMIT menuObjectPathChanged();
        initialize();
    }
}

QVariantMap SharedLomiriMenuModel::actions() const
{
    return m_actions;
}

void SharedLomiriMenuModel::setActions(const QVariantMap& actions)
{
    if (m_actions != actions) {
        m_actions = actions;
        Q_EMIT actionsChanged();
        initialize();
    }
}

UnityMenuModel* SharedLomiriMenuModel::model() const
{
    return m_model ? m_model.data() : nullptr;
}

void SharedLomiriMenuModel::initialize()
{
    if (m_busName.isEmpty() || m_menuObjectPath.isEmpty() || m_actions.isEmpty()) {
        if (!m_model.isNull()) {
            m_model.clear();
            Q_EMIT modelChanged();
        }
    } else {
        QSharedPointer<UnityMenuModel> model = LomiriMenuModelCache::singleton()->model(m_menuObjectPath);

        if (model != m_model) {
            if (model->busName() != m_busName) model->setBusName(m_busName);
            if (model->actions() != m_actions) model->setActions(m_actions);

            m_model = model;
            Q_EMIT modelChanged();
        } else if (m_model) {
            if (m_model->busName() != m_busName) m_model->setBusName(m_busName);
            if (m_model->actions() != m_actions) m_model->setActions(m_actions);
        }
    }
}
