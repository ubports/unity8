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
 */

#ifndef UNITY_MOCK_USERSMODEL_PRIVATE_H
#define UNITY_MOCK_USERSMODEL_PRIVATE_H

#include <QtCore/QList>
#include <QtCore/QString>

namespace QLightDM
{
class UsersModel;

class Entry
{
public:
    QString username;
    QString real_name;
    QString background;
    QString layouts;
    bool is_active;
    bool has_messages;
    QString session;
    QString infographic;
};

class UsersModelPrivate
{
public:
    explicit UsersModelPrivate(UsersModel *parent = 0);
    virtual ~UsersModelPrivate() = default;

    QList<Entry> entries;
    QString mockMode;

    void resetEntries();
protected:
    UsersModel * const q_ptr;

private:
    void resetEntries_single();
    void resetEntries_singlePassphrase();
    void resetEntries_singlePin();
    void resetEntries_full();
    Q_DECLARE_PUBLIC(UsersModel)
};

}

#endif // UNITY_MOCK_USERSMODEL_PRIVATE_H
