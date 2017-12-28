/*
 * Copyright (C) 2013-2016 Canonical, Ltd.
 * Copyright (C) 2010-2011 David Edmundson.
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

#pragma once

#include <QAbstractListModel>
#include <QList>
#include <QString>

namespace QLightDM
{
class UsersModelPrivate;

class Q_DECL_EXPORT UsersModel : public QAbstractListModel
{
    Q_OBJECT

public:
    explicit UsersModel(QObject *parent = 0);
    virtual ~UsersModel();

    enum UserModelRoles {NameRole = Qt::UserRole,
                         RealNameRole,
                         LoggedInRole,
                         BackgroundRole,
                         SessionRole,
                         HasMessagesRole,
                         ImagePathRole,
                         BackgroundPathRole,
                         UidRole
    };
    Q_ENUM(UserModelRoles)

    int rowCount(const QModelIndex &parent) const override;
    QVariant data(const QModelIndex &index, int role) const override;

    void setCurrentSessionName(const QString &sessionName, const QString &username);

private Q_SLOTS:
    void resetEntries();

private:
    UsersModelPrivate * const d_ptr;
    Q_DECLARE_PRIVATE(UsersModel)
};

}
