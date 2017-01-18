/*
 * Copyright (C) 2015-2016 Canonical, Ltd.
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
 */

#pragma once

#include <QAbstractListModel>
#include <QByteArray>
#include <QHash>
#include <QString>

namespace QLightDM
{
class SessionsModelPrivate;

class Q_DECL_EXPORT SessionsModel : public QAbstractListModel
    {
        Q_OBJECT

    public:
        enum SessionModelRoles {
            //name is exposed as Qt::DisplayRole
            //comment is exposed as Qt::TooltipRole
            KeyRole = Qt::UserRole,
            IdRole = KeyRole, /** Deprecated */
            TypeRole
        };
        Q_ENUM(SessionModelRoles)

        enum SessionType {
            LocalSessions,
            RemoteSessions
        };
        Q_ENUM(SessionType)

        explicit SessionsModel(QObject* parent=nullptr); /** Deprecated. Loads local sessions*/
        explicit SessionsModel(SessionsModel::SessionType, QObject* parent=nullptr);
        virtual ~SessionsModel();

        QHash<int, QByteArray> roleNames() const override;
        int rowCount(const QModelIndex& parent) const override;
        QVariant data(const QModelIndex& index, int role) const override;

    private Q_SLOTS:
        void resetEntries();

    private:
        SessionsModelPrivate *d_ptr;
        Q_DECLARE_PRIVATE(SessionsModel)
    };
}
