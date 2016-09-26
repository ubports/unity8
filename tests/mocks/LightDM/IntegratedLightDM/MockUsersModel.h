/*
 * Copyright (C) 2014 Canonical, Ltd.
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

#ifndef MOCK_UNITY_USERSMODEL_H
#define MOCK_UNITY_USERSMODEL_H

#include <UsersModel.h>

class MockUsersModel : public UsersModel
{
    Q_OBJECT

    Q_PROPERTY(QString mockMode READ mockMode WRITE setMockMode NOTIFY mockModeChanged)

public:
    explicit MockUsersModel(QObject* parent=0);

    QString mockMode() const;
    void setMockMode(QString mockMode);

Q_SIGNALS:
    void mockModeChanged(QString mode);
};

#endif // MOCK_UNITY_USERSMODEL_H
