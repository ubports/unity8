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

    m_indicatorData.clear();
    Q_EMIT indicatorDataChanged();

    endResetModel();
}


void FakeIndicatorsModel::append(const QVariantMap& row)
{
    QList<QVariant> data = m_indicatorData.toList();
    beginInsertRows(QModelIndex(), data.count(), data.count());

    data.append(row);
    m_indicatorData = data;
    Q_EMIT indicatorDataChanged();

    endInsertRows();
}

void FakeIndicatorsModel::setIndicatorData(const QVariant& indicatorData)
{
    beginResetModel();

    m_indicatorData = indicatorData;
    Q_EMIT indicatorDataChanged();

    endResetModel();
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

QVariant FakeIndicatorsModel::data(int row, int role) const
{
    return data(index(row, 0), role);
}

QVariant FakeIndicatorsModel::data(const QModelIndex &index, int role) const
{
    QList<QVariant> dataList = m_indicatorData.toList();
    if (!index.isValid() || index.row() >= dataList.size())
        return QVariant();

    return dataList[index.row()].toMap()[roleNames()[role]];
}

QModelIndex FakeIndicatorsModel::parent(const QModelIndex&) const
{
    return QModelIndex();
}

int FakeIndicatorsModel::rowCount(const QModelIndex&) const
{
    return m_indicatorData.toList().count();
}
