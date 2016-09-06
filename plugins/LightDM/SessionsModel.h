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

#ifndef UNITY_SESSIONSMODEL_H
#define UNITY_SESSIONSMODEL_H

#include <unitysortfilterproxymodelqml.h>
#include <QLightDM/SessionsModel>
#include <QtCore/QHash>
#include <QtCore/QObject>
#include <QtCore/QUrl>

class SessionsModel : public UnitySortFilterProxyModelQML
{
    Q_OBJECT

    Q_ENUMS(SessionModelRoles)

    Q_PROPERTY(QList<QUrl> iconSearchDirectories READ iconSearchDirectories
            WRITE setIconSearchDirectories NOTIFY iconSearchDirectoriesChanged)

    Q_PROPERTY(QObject *mock READ mock CONSTANT) // for testing

Q_SIGNALS:
    void iconSearchDirectoriesChanged();

public:
    enum SessionModelRoles {
        /* This is tricky / ugly. Since we are ultimately chaining 3 enums together,
         * the _first_ value of this enum MUST be the _last_ value of
         * QLightDM::SessionsModel::SessionModelRoles and consquently, this must
         * also match the last value in the corresponding enum of the integrated lib
         */
        TypeRole = QLightDM::SessionsModel::SessionModelRoles::TypeRole,
        IconRole
    };

    explicit SessionsModel(QObject* parent=nullptr);

    QHash<int, QByteArray>  roleNames() const override;
    int rowCount(const QModelIndex& parent) const override;
    QVariant data(const QModelIndex& index, int role) const override;
    QList<QUrl> iconSearchDirectories() const;
    Q_INVOKABLE QUrl iconUrl(const QString sessionName) const;

    void setIconSearchDirectories(const QList<QUrl> searchDirectories);

    QObject *mock();

private:
    QLightDM::SessionsModel* m_model;
    QHash<int, QByteArray> m_roleNames;
    QList<QUrl> m_iconSearchDirectories{
        QUrl("/usr/share/unity8/Greeter/graphics/session_icons"),
        QUrl("/usr/local/share/unity-greeter"),
        QUrl("/usr/share/unity-greeter/")};

};

#endif // UNITY_SESSIONSMODEL_H
