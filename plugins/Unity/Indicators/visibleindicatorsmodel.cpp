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
#include "indicators.h"

VisibleIndicatorsModel::VisibleIndicatorsModel(QObject *parent)
    : QIdentityProxyModel(parent),
      m_inserting(false)
{
    QObject::connect(this, SIGNAL(rowsAboutToBeInserted(QModelIndex, int, int)), this, SLOT(onBeginRowInserted(QModelIndex, int, int)));
    QObject::connect(this, SIGNAL(rowsInserted(QModelIndex, int, int)), this, SLOT(onRowInserted(QModelIndex, int, int)));
}

QHash<int, QByteArray> VisibleIndicatorsModel::roleNames() const
{
    static QHash<int, QByteArray> roles;
    if (roles.isEmpty())
    {
        roles[IndicatorsModelRole::Identifier] = "identifier";
        roles[IndicatorsModelRole::Position] = "position";
        roles[IndicatorsModelRole::IndicatorProperties] = "indicatorProperties";
        roles[IndicatorsModelRole::IsVisible] = "isVisible";
    }
    return roles;
}

void VisibleIndicatorsModel::setSourceModel(QAbstractItemModel *model)
{
    if (sourceModel() != model) {
        QIdentityProxyModel::setSourceModel(model);
        Q_EMIT modelChanged();
    }
}

QVariantMap VisibleIndicatorsModel::visible() const
{
    return m_visible;
}

void VisibleIndicatorsModel::onBeginRowInserted(const QModelIndex&, int, int)
{
    m_inserting = true;
}

void VisibleIndicatorsModel::onRowInserted(const QModelIndex&, int, int)
{
    m_inserting = false;
}

void VisibleIndicatorsModel::setVisible(const QVariantMap& visible)
{
    if (m_visible != visible) {
        m_visible = visible;
        Q_EMIT visibleChanged();

        // need to tell the view that the visible data has changed.
        if (!m_inserting && rowCount() > 0) {
            Q_EMIT dataChanged(index(0, 0), index(rowCount() - 1, 0), QVector<int>() << IndicatorsModelRole::IsVisible);
        }
    }
}

QVariant VisibleIndicatorsModel::data(const QModelIndex &index, int role) const
{
    if (role != IndicatorsModelRole::IsVisible) {
        return QIdentityProxyModel::data(index, role);
    }

    if (!index.isValid()) {
        return false;
    }

    QString ident = QIdentityProxyModel::data(index, IndicatorsModelRole::Identifier).toString();
    return m_visible.value(ident, false).toBool();
}
