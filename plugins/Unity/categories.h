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

// unity-core
#include <UnityCore/Scope.h>

// dee-qt
#include "deelistmodel.h"

#include <QPointer>
#include <QSet>
#include <QTimer>

class Categories : public DeeListModel
{
    Q_OBJECT

    Q_ENUMS(Roles)

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

    /* setters */
    void setUnityScope(const unity::dash::Scope::Ptr& scope);

private Q_SLOTS:
    void onCountChanged();
    void onEmitCountChanged();

private:
    void onCategoriesModelChanged(unity::glib::Object<DeeModel> model);

    DeeListModel* getFilter(int index) const;

    unity::dash::Scope::Ptr m_unityScope;
    QTimer m_timer;
    QSet<int> m_updatedCategories;
    QHash<int, QByteArray> m_roles;
    mutable QMap<int, QPointer<DeeListModel>> m_results;
};

#endif // CATEGORIES_H
