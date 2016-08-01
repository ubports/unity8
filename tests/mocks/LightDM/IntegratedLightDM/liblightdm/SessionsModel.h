/*
 * Copyright (C) 2015 Canonical, Ltd.
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

#ifndef UNITY_MOCK_SESSIONSMODEL_H
#define UNITY_MOCK_SESSIONSMODEL_H

#include <QtCore/QAbstractListModel>
#include <QtCore/QString>

namespace QLightDM
{
class SessionsModelPrivate;

class Q_DECL_EXPORT SessionsModel : public QAbstractListModel
    {
        Q_OBJECT

        Q_ENUMS(SessionModelRoles SessionType)

        // Mock-only API for testing purposes
        Q_PROPERTY(QString testScenario READ testScenario WRITE setTestScenario)

    public:

        enum SessionModelRoles {
            //name is exposed as Qt::DisplayRole
            //comment is exposed as Qt::TooltipRole
            KeyRole = Qt::UserRole,
            IdRole = KeyRole, /** Deprecated */
            TypeRole
        };

        enum SessionType {
            LocalSessions,
            RemoteSessions
        };

        explicit SessionsModel(QObject* parent=nullptr); /** Deprecated. Loads local sessions*/
        explicit SessionsModel(SessionsModel::SessionType, QObject* parent=nullptr);
        virtual ~SessionsModel();

        QHash<int, QByteArray> roleNames() const override;
        int rowCount(const QModelIndex& parent) const override;
        QVariant data(const QModelIndex& index, int role) const override;

        QString testScenario() const;
        void setTestScenario(QString testScenario);

    protected:
        SessionsModelPrivate* const d_ptr;

    private:
        QHash<int, QByteArray> m_roleNames;
        Q_DECLARE_PRIVATE(SessionsModel)
    };
}

#endif // UNITY_MOCK_SESSIONSMODEL_H
