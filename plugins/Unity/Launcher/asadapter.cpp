/*
 * Copyright 2014 Canonical Ltd.
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
 *
 * Authors:
 *      Michael Zanetti <michael.zanetti@canonical.com>
 */

#include "asadapter.h"
#include "launcheritem.h"
#include "AccountsServiceDBusAdaptor.h"

#include <QDebug>

ASAdapter::ASAdapter()
{
    m_accounts = new AccountsServiceDBusAdaptor();
    m_user = qgetenv("USER");
    if (m_user.isEmpty()) {
        qWarning() << "$USER not valid. Account Service integration will not work.";
    }
}

ASAdapter::~ASAdapter()
{
    m_accounts->deleteLater();
}

void ASAdapter::syncItems(QList<LauncherItem *> m_list)
{
    if (m_accounts && !m_user.isEmpty()) {
        QList<QVariantMap> items;

        Q_FOREACH(LauncherItem *item, m_list) {
            items << itemToVariant(item);
        }

        m_accounts->setUserPropertyAsync(m_user, "com.canonical.unity.AccountsService", "launcher-items", QVariant::fromValue(items));
    }
}

QVariantMap ASAdapter::itemToVariant(LauncherItem *item) const
{
    QVariantMap details;
    details.insert("id", item->appId());
    details.insert("name", item->name());
    details.insert("icon", item->icon());
    details.insert("count", item->count());
    details.insert("countVisible", item->countVisible());
    return details;
}
