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
#include <QObject>
#include <QSet>
#include <QTimer>

#include <dee.h>
#include <deelistmodel.h>

class Categories : public DeeListModel
{
    Q_OBJECT

    Q_ENUMS(Roles)
  
public:
    Categories(QObject* parent = 0);
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
    void setResultModel(DeeModel* model);

private Q_SLOTS:
    void onCountChanged();
    void onEmitCountChanged();

private:
    DeeModel* getResultsForCategory(unsigned index) const;
    DeeListModel* getFilter(int index) const;

    DeeModel* m_dee_results;
    QTimer m_timer;
    QSet<DeeListModel*> m_timerFilters;
    QHash<int, QByteArray> m_roles;
    mutable QMap<int, DeeListModel*> m_filters;
};

#endif // FAKE_CATEGORIES_H
