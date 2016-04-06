/*
 * Copyright 2014-2015 Canonical Ltd.
 *
 * This program is free software; you can redistribute it and/or modify
 * it under the terms of the GNU Lesser General Public License as published by
 * the Free Software Foundation; version 3.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU Lesser General Public License for more details.
 *
 * You should have received a copy of the GNU Lesser General Public License
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.
 */

#include "asadapter.h"
#include "launcheritem.h"
#include "AccountsServiceDBusAdaptor.h"

#include <unistd.h>
#include <sys/types.h>
#include <pwd.h>

#include <QDebug>

ASAdapter::ASAdapter()
{
    m_accounts = new AccountsServiceDBusAdaptor();

    auto pw = getpwuid(getuid());
    m_user = pw->pw_name;

    if (m_user.isEmpty()) {
        qWarning() << "username not valid. Account Service integration will not work.";
    }
}

ASAdapter::~ASAdapter()
{
    m_accounts->deleteLater();
}

void ASAdapter::syncItems(const QList<LauncherItem*> &list)
{
    if (m_accounts && !m_user.isEmpty()) {
        QList<QVariantMap> items;
        items.reserve(list.count());

        Q_FOREACH(LauncherItem *item, list) {
            items << itemToVariant(item);
        }

        m_accounts->setUserPropertyAsync(m_user, QStringLiteral("com.canonical.unity.AccountsService"), QStringLiteral("LauncherItems"), QVariant::fromValue(items));
    }
}

QVariantMap ASAdapter::itemToVariant(LauncherItem *item) const
{
    QVariantMap details;
    details.insert(QStringLiteral("id"), item->appId());
    details.insert(QStringLiteral("name"), item->name());
    details.insert(QStringLiteral("icon"), item->icon());
    details.insert(QStringLiteral("count"), item->count());
    details.insert(QStringLiteral("countVisible"), item->countVisible());
    details.insert(QStringLiteral("pinned"), item->pinned());
    details.insert(QStringLiteral("running"), item->running());
    details.insert(QStringLiteral("progress"), item->progress());
    return details;
}
