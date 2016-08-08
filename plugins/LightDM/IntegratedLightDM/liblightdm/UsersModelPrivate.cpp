/*
 * Copyright (C) 2013-2016 Canonical, Ltd.
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

#include "AccountsServiceDBusAdaptor.h"
#include "UsersModel.h"

#include <glib.h>
#include <QDebug>
#include <QDir>
#include <QSettings>
#include <QStringList>
#include <unistd.h>

namespace QLightDM
{

UsersModelPrivate::UsersModelPrivate(UsersModel* parent)
  : QObject(parent),
    q_ptr(parent),
    m_service(new AccountsServiceDBusAdaptor(this))
{
    QFileInfo demoFile(QDir::homePath() + "/.unity8-greeter-demo");
    QString currentUser = g_get_user_name();
    uid_t currentUid = getuid();

    if (demoFile.exists()) {
        QSettings settings(demoFile.filePath(), QSettings::NativeFormat);
        QStringList users = settings.value(QStringLiteral("users"), QStringList() << currentUser).toStringList();

        entries.reserve(users.count());
        Q_FOREACH(const QString &user, users)
        {
            QString name = settings.value(user + "/name", user).toString();
            entries.append({user, name, 0, 0, false, false, 0, 0, currentUid++});
        }
    } else {
        entries.append({currentUser, 0, 0, 0, false, false, 0, 0, currentUid});

        connect(m_service, &AccountsServiceDBusAdaptor::maybeChanged,
                this, [this](const QString &user) {
            if (user == entries[0].username) {
                updateName(true);
            }
        });
        updateName(false);
    }
}

void UsersModelPrivate::updateName(bool async)
{
    auto pendingReply = m_service->getUserPropertyAsync(entries[0].username,
                                                        QStringLiteral("org.freedesktop.Accounts.User"),
                                                        QStringLiteral("RealName"));
    auto *watcher = new QDBusPendingCallWatcher(pendingReply, this);

    connect(watcher, &QDBusPendingCallWatcher::finished,
            this, [this](QDBusPendingCallWatcher* watcher) {

        QDBusPendingReply<QVariant> reply = *watcher;
        watcher->deleteLater();
        if (reply.isError()) {
            qWarning() << "Failed to get 'RealName' property - " << reply.error().message();
            return;
        }

        const QString realName = reply.value().toString();
        if (entries[0].real_name != realName) {
            entries[0].real_name = realName;
            Q_EMIT dataChanged(0);
        }
    });
    if (!async) {
        watcher->waitForFinished();
    }
}

}
