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
 */

// self
#include "visibleindicatorsmodel.h"
#include "rootactionstate.h"
#include "indicatorsmodel.h"
#include "indicators.h"

#include <unitymenumodel.h>

// Qt
#include <QDebug>

VisibleIndicatorsModel::VisibleIndicatorsModel(QObject *parent)
    : QIdentityProxyModel(parent),
      m_model(NULL)
{
    connect(this, SIGNAL(modelReset()), SIGNAL(countChanged()));
    connect(this, SIGNAL(rowsInserted(QModelIndex,int,int)), SIGNAL(countChanged()));
    connect(this, SIGNAL(rowsRemoved(QModelIndex,int,int)), SIGNAL(countChanged()));
}

VisibleIndicatorsModel::~VisibleIndicatorsModel()
{
    qDeleteAll(m_rootActions);
    m_rootActions.clear();
    m_visible.clear();
}

QHash<int, QByteArray> VisibleIndicatorsModel::roleNames() const
{
    return sourceModel() ? sourceModel()->roleNames() : QHash<int, QByteArray>();
}

QByteArray VisibleIndicatorsModel::profile() const
{
    return m_profile;
}

void VisibleIndicatorsModel::setProfile(const QByteArray& profile)
{
    if (m_profile != profile) {
        m_profile = profile;
        Q_EMIT profileChanged();
    }
}

IndicatorsModel* VisibleIndicatorsModel::model() const
{
    return m_model;
}

void VisibleIndicatorsModel::setModel(IndicatorsModel *itemModel)
{
    if (itemModel != m_model) {
        m_model = itemModel;
        if (sourceModel() != NULL) {
            sourceModel()->disconnect(this);
        }

        setSourceModel(itemModel);

        if (sourceModel() != NULL) {
            // ... and use our own
            connect(sourceModel(), SIGNAL(rowsInserted(QModelIndex,int,int)),
                    SLOT(sourceRowsInserted(QModelIndex,int,int)));
            connect(sourceModel(), SIGNAL(rowsAboutToBeRemoved(QModelIndex,int,int)),
                    SLOT(sourceRowsAboutToBeRemoved(QModelIndex,int,int)));
            connect(sourceModel(), SIGNAL(dataChanged(QModelIndex,QModelIndex)),
                    SLOT(sourceDataChanged(QModelIndex,QModelIndex)));
        }
        Q_EMIT modelChanged();
    }
}

void VisibleIndicatorsModel::sourceRowsInserted(const QModelIndex&, int start, int end)
{
    if (!m_model) {
        return;
    }

    for (int row = start; row <= end; row++) {
        const QModelIndex idx = sourceModel()->index(row, 0);
        if (!idx.isValid()) {
            continue;
        }

        RootActionState* actionState = new RootActionState();
        connect(actionState, SIGNAL(updated()), SLOT(onActionStateUpdated()));
        m_rootActions.insert(row, actionState);
        m_visible.insert(row, false);

        UnityMenuModel* unityModel = qobject_cast<UnityMenuModel*>(m_model->getMenuModelForIndexProfile(idx, profile()));
        actionState->setMenu(unityModel);
    }
}

void VisibleIndicatorsModel::sourceRowsAboutToBeRemoved(const QModelIndex&, int start, int end)
{
    for (int row = start; row <= end; row++) {

        if (m_rootActions.count() > start) {
            delete m_rootActions[start];
            m_rootActions.removeAt(start);
        }
        if (m_visible.count() > start) {
            m_visible.removeAt(start);
        }
    }
}

void VisibleIndicatorsModel::sourceDataChanged(const QModelIndex& topRight, const QModelIndex& bottomRight)
{
    for (int row = topRight.row(); row <= bottomRight.row(); row++) {

        const QModelIndex idx = sourceModel()->index(row, 0);
        if (!idx.isValid()) {
            continue;
        }
        if (m_rootActions.count() <= row) {
            break;
        }

        UnityMenuModel* unityModel = qobject_cast<UnityMenuModel*>(m_model->getMenuModelForIndexProfile(idx, profile()));
        m_rootActions[row]->setMenu(unityModel);
    }
}

void VisibleIndicatorsModel::onActionStateUpdated()
{
    RootActionState* actionState = qobject_cast<RootActionState*>(sender());
    int changedRow = m_rootActions.indexOf(actionState);

    QModelIndex modelIndex = this->index(changedRow, 0);
    if (!modelIndex.isValid()) {
        return;
    }

    while (m_visible.count() <= changedRow) {
        m_visible.append(false);
    }

    if (actionState->isVisible() != m_visible[changedRow]) {
        m_visible[changedRow] = actionState->isVisible();

        Q_EMIT dataChanged(modelIndex, modelIndex, QVector<int>() << IndicatorsModelRole::IsVisible);
    }
}

QVariant VisibleIndicatorsModel::data(const QModelIndex &index, int role) const
{
    if (role != IndicatorsModelRole::IsVisible)
        return QIdentityProxyModel::data(index, role);

    if (!index.isValid() || m_visible.count() <= index.row())
        return false;

    return m_visible[index.row()];
}
