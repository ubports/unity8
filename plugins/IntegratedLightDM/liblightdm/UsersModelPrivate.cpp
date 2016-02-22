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

#include <glib.h>
#include <QDir>
#include <QSettings>
#include <QStringList>

namespace QLightDM
{

UsersModelPrivate::UsersModelPrivate(UsersModel* parent)
  : q_ptr(parent)
{
    QFileInfo demoFile(QDir::homePath() + "/.unity8-greeter-demo");
    QString currentUser = g_get_user_name();

    if (demoFile.exists()) {
        QSettings settings(demoFile.filePath(), QSettings::NativeFormat);
        QStringList users = settings.value(QStringLiteral("users"), QStringList() << currentUser).toStringList();

        entries.reserve(users.count());
        Q_FOREACH(const QString &user, users)
        {
            QString name = settings.value(user + "/name", user).toString();
            entries.append({user, name, 0, 0, false, false, 0, 0});
        }
    } else {
        // If we were using the actual liblightdm, we could just ask it
        // for the user's real name.  But we aren't.  We *should* ask
        // AccountsService for the real name, like liblightdm does internally,
        // but this is close enough since AS and passwd are always in sync.
        QString realName = QString::fromUtf8(g_get_real_name()); // gets name from passwd entry
        if (realName == QStringLiteral("Unknown")) { // glib doesn't translate this string
            realName.clear();
        }
        entries.append({currentUser, realName, 0, 0, false, false, 0, 0});
    }
}

}
