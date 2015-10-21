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

#include "UsersModelPrivate.h"

#include <QDir>
#include <QSettings>
#include <QStringList>

namespace QLightDM
{

UsersModelPrivate::UsersModelPrivate(UsersModel* parent)
  : q_ptr(parent)
{
    QSettings settings(QDir::homePath() + "/.unity8-greeter-demo", QSettings::NativeFormat);
    QStringList users = settings.value(QStringLiteral("users"), QStringList() << qgetenv("USER")).toStringList();

    entries.reserve(users.count());
    Q_FOREACH(const QString &user, users)
    {
        QVariant defaultValue = QString(user[0].toUpper() + user.mid(1));
        QString name = settings.value(user + "/name", defaultValue).toString();
        entries.append({user, name, 0, 0, false, false, 0, 0});
    }
}

}
