/*
 * Copyright (C) 2013 Canonical, Ltd.
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

#ifndef FAKE_CATEGORIES_H
#define FAKE_CATEGORIES_H

// Qt
#include <QAbstractListModel>

class ResultsModel;

class Categories : public QAbstractListModel
{
    Q_OBJECT

    Q_ENUMS(Roles)

public:
    Categories(int category_count, QObject* parent = 0);
    enum Roles {
        RoleCategoryId,
        RoleName,
        RoleIcon,
        RoleRawRendererTemplate,
        RoleRenderer,
        RoleComponents,
        RoleProgressSource, // maybe
        RoleResults,
        RoleCount
    };

    QVariant data(const QModelIndex& index, int role = Qt::DisplayRole) const override;
    QHash<int, QByteArray> roleNames() const override;
    int rowCount(const QModelIndex& parent = QModelIndex()) const override;

private:
    mutable QHash<int, ResultsModel*> m_resultsModels;
    QHash<int, QByteArray> m_roles;
    int m_category_count;
};

#endif // FAKE_CATEGORIES_H
