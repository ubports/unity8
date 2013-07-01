/*
 * Copyright (C) 2013 Canonical, Ltd.
 *
 * Authors:
 *  Michał Sawicz <michal.sawicz@canonical.com>
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


#ifndef CATEGORY_RESULTS_H
#define CATEGORY_RESULTS_H

// dee-qt
#include "deelistmodel.h"

class CategoryResults : public DeeListModel
{
    Q_OBJECT

    Q_ENUMS(Roles)

    Q_PROPERTY(int categoryIndex READ categoryIndex WRITE setCategoryIndex NOTIFY categoryIndexChanged)

public:
    explicit CategoryResults(QObject* parent = 0);
    ~CategoryResults();

    enum Roles {
        RoleUri,
        RoleIconHint,
        RoleCategory,
        //RoleResultType, // not needed
        RoleMimetype,
        RoleTitle,
        RoleComment,
        RoleDndUri,
        RoleMetadata
    };

    QVariant data(const QModelIndex& index, int role = Qt::DisplayRole) const;

    QHash<int, QByteArray> roleNames() const;

    /* getters */
    int categoryIndex() const;

    /* setters */
    void setCategoryIndex(int index);

Q_SIGNALS:
    void categoryIndexChanged(int index);

private:
    QHash<int, QByteArray> m_roles;
    int m_category_index;
};

#endif // CATEGORY_RESULTS_H
