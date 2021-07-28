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

#ifndef ASADAPTER_H
#define ASADAPTER_H

#include <QVariantMap>

class LauncherItem;
class AccountsServiceDBusAdaptor;

class ASAdapter
{
public:
    ASAdapter();
    ~ASAdapter();

    ASAdapter(const ASAdapter&) = delete;
    ASAdapter& operator=(const ASAdapter&) = delete;

    void syncItems(const QList<LauncherItem*> &list);

private:
    QVariantMap itemToVariant(LauncherItem *item) const;

private:
    AccountsServiceDBusAdaptor *m_accounts;
    QString m_user;

    friend class LauncherModelTest;
};

#endif
