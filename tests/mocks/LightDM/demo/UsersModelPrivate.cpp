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
 *
 * Author: Michael Terry <michael.terry@canonical.com>
 */

#include "../UsersModelPrivate.h"

#include <QDir>
#include <QSettings>
#include <QStringList>

namespace QLightDM
{

UsersModelPrivate::UsersModelPrivate(UsersModel* parent)
  : q_ptr(parent)
{
    QSettings settings(QDir::homePath() + "/.unity8-greeter-demo", QSettings::NativeFormat);
    QStringList users = settings.value("users", QStringList() << "phablet").toStringList();

    Q_FOREACH(QString user, users)
    {
        entries.append({user, user[0].toUpper() + user.mid(1),
                        0, 0, false, false, 0, 0});
    }
}

}
