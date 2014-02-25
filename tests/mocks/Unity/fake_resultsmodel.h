/*
 * Copyright (C) 2013 Canonical, Ltd.
 *
 * Authors:
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


#ifndef FAKE_RESULTS_MODEL_H
#define FAKE_RESULTS_MODEL_H

#include <QAbstractListModel>

class ResultsModel : public QAbstractListModel
{
    Q_OBJECT

    Q_ENUMS(Roles)

    Q_PROPERTY(QString categoryId READ categoryId WRITE setCategoryId NOTIFY categoryIdChanged)
    Q_PROPERTY(int count READ count NOTIFY countChanged)

public:
    explicit ResultsModel(int result_count, int categoryId, QObject* parent = 0);

    enum Roles {
        RoleUri,
        RoleCategoryId,
        RoleDndUri,
        RoleResult,
        // card components
        RoleTitle,
        RoleArt,
        RoleSubtitle,
        RoleMascot,
        RoleEmblem,
        RoleOldPrice,
        RolePrice,
        RoleAltPrice,
        RoleRating,
        RoleAltRating,
        RoleSummary
    };

    int rowCount(const QModelIndex& parent = QModelIndex()) const override;
    QHash<int, QByteArray> roleNames() const override;
    QVariant data(const QModelIndex& index, int role = Qt::DisplayRole) const override;

    Q_INVOKABLE QVariant get(int row) const;

    /* getters */
    QString categoryId() const;
    int count() const;

    /* setters */
    void setCategoryId(QString const& id);

Q_SIGNALS:
    void categoryIdChanged();
    void countChanged();

private:
    QHash<int, QByteArray> m_roles;
    int m_result_count;
    int m_categoryId;
};

#endif // FAKE_RESULTS_MODEL_H
