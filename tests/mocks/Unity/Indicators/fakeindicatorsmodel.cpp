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
 * Authors:
 *      Nick Dedekind <nick.dedekind@canonical.com>
 */

#include "fakeindicatorsmodel.h"
#include "indicators.h"

FakeIndicatorsModel::FakeIndicatorsModel(QObject *parent)
    : QAbstractListModel(parent)
{
    QObject::connect(this, SIGNAL(rowsInserted(const QModelIndex &, int, int)), this, SIGNAL(countChanged()));
    QObject::connect(this, SIGNAL(rowsRemoved(const QModelIndex &, int, int)), this, SIGNAL(countChanged()));
    QObject::connect(this, SIGNAL(modelReset()), this, SIGNAL(countChanged()));
}

/*! \internal */
FakeIndicatorsModel::~FakeIndicatorsModel()
{
    qDeleteAll(m_indicators);
}

int FakeIndicatorsModel::count() const
{
    return rowCount();
}

void FakeIndicatorsModel::load(const QString&)
{
}

void FakeIndicatorsModel::unload()
{
    beginResetModel();

    qDeleteAll(m_indicators);
    m_indicators.clear();

    endResetModel();
}


void FakeIndicatorsModel::append(const QVariantMap& row)
{
    Indicator* new_row = new QHash<int, QVariant>();
    for (auto iter = row.begin(); iter != row.end(); ++iter )
    {
        int key = roleNames().key(iter.key().toUtf8(), -1);
        if (key != -1) {
            new_row->insert(key, iter.value());
        }
    }

    beginInsertRows(QModelIndex(), m_indicators.count(), m_indicators.count());

    m_indicators.append(new_row);

    endInsertRows();
}

QHash<int, QByteArray> FakeIndicatorsModel::roleNames() const
{
    static QHash<int, QByteArray> roles;
    if (roles.isEmpty())
    {
        roles[IndicatorsModelRole::Identifier] = "identifier";
        roles[IndicatorsModelRole::Position] = "position";
        roles[IndicatorsModelRole::WidgetSource] = "widgetSource";
        roles[IndicatorsModelRole::PageSource] = "pageSource";
        roles[IndicatorsModelRole::IndicatorProperties] = "indicatorProperties";
    }
    return roles;
}

int FakeIndicatorsModel::columnCount(const QModelIndex &) const
{
    return 1;
}

Q_INVOKABLE QVariant FakeIndicatorsModel::data(int row, int role) const
{
    return data(index(row, 0), role);
}

QVariant FakeIndicatorsModel::data(const QModelIndex &index, int role) const
{
    if (!index.isValid() || index.row() >= m_indicators.size())
        return QVariant();

    Indicator* indicator = m_indicators[index.row()];
    return indicator->value(role, QVariant());
}

QModelIndex FakeIndicatorsModel::parent(const QModelIndex&) const
{
    return QModelIndex();
}

int FakeIndicatorsModel::rowCount(const QModelIndex&) const
{
    return m_indicators.count();
}
