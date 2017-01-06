/*
 * Copyright (C) 2013,2015-2016 Canonical, Ltd.
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
 * Author: Michael Terry <michael.terry@canonical.com>
 */

#include "Greeter.h"
#include "UsersModel.h"
#include <QLightDM/UsersModel>
#include <QtCore/QSortFilterProxyModel>

#include <libintl.h>

// First, we define an internal class that wraps LightDM's UsersModel.  This
// class will modify some of the data coming from LightDM.  For example, we
// modify any empty Real Names into just normal Names.
// (We can't modify the data directly in UsersModel below because it won't sort
// using the modified data.)
class MangleModel : public QSortFilterProxyModel
{
    Q_OBJECT

public:
    explicit MangleModel(QObject* parent=0);

    QVariant data(const QModelIndex &index, int role = Qt::DisplayRole) const override;
};

MangleModel::MangleModel(QObject* parent)
  : QSortFilterProxyModel(parent)
{
    setSourceModel(new QLightDM::UsersModel(this));
}

QVariant MangleModel::data(const QModelIndex &index, int role) const
{
    QVariant variantData = QSortFilterProxyModel::data(index, role);

    // If user's real name is empty, switch to unix name
    if (role == QLightDM::UsersModel::RealNameRole && variantData.toString().isEmpty()) {
        variantData = QSortFilterProxyModel::data(index, QLightDM::UsersModel::NameRole);
    } else if (role == QLightDM::UsersModel::BackgroundPathRole && variantData.toString().startsWith('#')) {
        const QString stringData = "data:image/svg+xml,<svg><rect width='100%' height='100%' fill='" + variantData.toString() + "'/></svg>";
        variantData = stringData;
    }

    return variantData;
}

// **** Now we continue with actual UsersModel class ****

UsersModel::UsersModel(QObject* parent)
  : UnitySortFilterProxyModelQML(parent)
{
    setModel(new MangleModel(this));
    setSortCaseSensitivity(Qt::CaseInsensitive);
    setSortLocaleAware(true);
    setSortRole(QLightDM::UsersModel::RealNameRole);
    sort(0);
}

int UsersModel::guestRow() const
{
    return Greeter::instance()->hasGuestAccount() ?
           UnitySortFilterProxyModelQML::rowCount() : -1;
}

int UsersModel::rowCount(const QModelIndex &parent) const
{
    auto count = UnitySortFilterProxyModelQML::rowCount(parent);

    if (Greeter::instance()->hasGuestAccount() && !parent.isValid())
        count++;

    return count;
}

QModelIndex UsersModel::index(int row, int column, const QModelIndex &parent) const
{
    if (row == guestRow() && !parent.isValid()) {
        return createIndex(row, column);
    } else {
        return UnitySortFilterProxyModelQML::index(row, column, parent);
    }
}

QVariant UsersModel::data(const QModelIndex &index, int role) const
{
    if (index.row() == guestRow() && index.column() == 0) {
        switch (role) {
        case QLightDM::UsersModel::NameRole:       return QStringLiteral("*guest");
        case QLightDM::UsersModel::RealNameRole:   return gettext("Guest Session");
        default:                                   return QVariant();
        }
    }

    return QSortFilterProxyModel::data(index, role);
}

#include "UsersModel.moc"
