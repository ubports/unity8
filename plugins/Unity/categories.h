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


#ifndef CATEGORIES_H
#define CATEGORIES_H

// dee-qt
#include "deelistmodel.h"

#include <QSet>
#include <QTimer>

class CategoryFilter;

class Categories : public DeeListModel
{
    Q_OBJECT

    Q_ENUMS(Roles)

    Q_PROPERTY(DeeListModel* resultModel READ resultModel WRITE setResultModel NOTIFY resultModelChanged)

public:
    explicit Categories(QObject* parent = 0);
    ~Categories();

    enum Roles {
        RoleId,
        RoleName,
        RoleIcon,
        RoleRenderer,
        RoleContentType,
        RoleHints,
        RoleResults,
        RoleCount
    };

    QVariant data(const QModelIndex& index, int role = Qt::DisplayRole) const;

    QHash<int, QByteArray> roleNames() const;

    /* getters */
    DeeListModel* resultModel() { return m_resultModel; }

    /* setters */
    void setResultModel(DeeListModel*);

Q_SIGNALS:
    void resultModelChanged(DeeListModel*);

private Q_SLOTS:
    void onCountChanged();
    void onEmitCountChanged();

private:
    CategoryFilter* getFilter(int index) const;

    QTimer m_timer;
    QSet<CategoryFilter*> m_timerFilters;
    QHash<int, QByteArray> m_roles;
    DeeListModel* m_resultModel;
    mutable QMap<int, CategoryFilter*> m_filters;
};

#endif // CATEGORIES_H
