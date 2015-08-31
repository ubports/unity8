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
    : QAbstractListModel(parent),
      m_profile("phone")
{
    QObject::connect(this, &FakeIndicatorsModel::rowsInserted, this, &FakeIndicatorsModel::countChanged);
    QObject::connect(this, &FakeIndicatorsModel::rowsRemoved, this, &FakeIndicatorsModel::countChanged);
    QObject::connect(this, &FakeIndicatorsModel::modelReset, this, &FakeIndicatorsModel::countChanged);
}

/*! \internal */
FakeIndicatorsModel::~FakeIndicatorsModel()
{
}

int FakeIndicatorsModel::count() const
{
    return rowCount();
}

QString FakeIndicatorsModel::profile() const
{
    return m_profile;
}

void FakeIndicatorsModel::setProfile(const QString& profile)
{
    m_profile = profile;
    Q_EMIT profileChanged();
}

void FakeIndicatorsModel::load(const QString&)
{
}

void FakeIndicatorsModel::unload()
{
    beginResetModel();

    m_modelData.clear();
    Q_EMIT modelDataChanged();

    endResetModel();
}


void FakeIndicatorsModel::append(const QVariantMap& data)
{
    QList<QVariant> allData = m_modelData.toList();
    beginInsertRows(QModelIndex(), allData.count(), allData.count());

    allData.append(data);
    m_modelData = allData;
    Q_EMIT modelDataChanged();

    endInsertRows();
}

void FakeIndicatorsModel::insert(int row, const QVariantMap& data)
{
    QList<QVariant> allData = m_modelData.toList();
    row = qMax(0, qMin(row, allData.count()));

    beginInsertRows(QModelIndex(), row, row);

    allData.insert(row, data);
    m_modelData = allData;
    Q_EMIT modelDataChanged();

    endInsertRows();
}

void FakeIndicatorsModel::remove(int row)
{
    QList<QVariant> allData = m_modelData.toList();
    row = qMax(0, qMin(row, allData.count()));

    beginRemoveRows(QModelIndex(), row, row);

    allData.removeAt(row);
    m_modelData = allData;
    Q_EMIT modelDataChanged();

    endRemoveRows();
}

void FakeIndicatorsModel::setModelData(const QVariant& modelData)
{
    beginResetModel();

    m_modelData = modelData;
    Q_EMIT modelDataChanged();

    endResetModel();
}

QHash<int, QByteArray> FakeIndicatorsModel::roleNames() const
{
    static QHash<int, QByteArray> roles;
    if (roles.isEmpty())
    {
        roles[IndicatorsModelRole::Identifier] = "identifier";
        roles[IndicatorsModelRole::Position] = "position";
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
    QList<QVariant> dataList = m_modelData.toList();
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
    return m_modelData.toList().count();
}
