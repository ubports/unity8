/*
 * Copyright (C) 2013 Canonical, Ltd.
 *
 * Authors:
 *  Michał Sawicz <michal.sawicz@canonical.com>
 *  Michal Hruby <michal.hruby@canonical.com>
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

// local
#include "signalslist.h"

class Categories : public DeeListModel
{
    Q_OBJECT

    Q_ENUMS(Roles)

public:
    explicit Categories(QObject* parent = 0);

    enum Roles {
        RoleCategoryId,
        RoleName,
        RoleIcon,
        RoleRenderer,
        RoleContentType,
        RoleRendererHint,
        RoleProgressSource,
        RoleHints,
        RoleResults,
        RoleCount
    };

    Q_INVOKABLE void overrideResults(const QString& categoryId, QAbstractItemModel* model);

    QVariant data(const QModelIndex& index, int role = Qt::DisplayRole) const;

    QHash<int, QByteArray> roleNames() const;

    /* setters */
    void setUnityScope(const unity::dash::Scope::Ptr& scope);

private Q_SLOTS:
    void onCountChanged();
    void onRowCountChanged();
    void onEmitCountChanged();
    void onOverrideModelDestroyed();

private:
    void onCategoriesModelChanged(unity::glib::Object<DeeModel> model);
    void onCategoryOrderChanged(const std::vector<unsigned int>& cat_order);

    DeeListModel* getResults(int index) const;

    unity::dash::Scope::Ptr m_unityScope;
    QTimer m_timer;
    QSet<int> m_updatedCategories;
    QHash<int, QByteArray> m_roles;
    QMap<QString, QAbstractItemModel*> m_overriddenCategories;
    mutable QMap<int, DeeListModel*> m_results;
    SignalsList m_signals;

    /* Category order array contains indices of actual categories in the underlying DeeListModel.
       It's used internally to reflect category order reported by scope.
     */
    mutable QList<unsigned int> m_categoryOrder;
};

#endif // CATEGORIES_H
