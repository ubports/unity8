/*
 * Copyright 2013 Canonical Ltd.
 *
 * This program is free software: you can redistribute it and/or modify it
 * under the terms of the GNU General Public License version 3, as published
 * by the  Free Software Foundation.
 *
 * This program is distributed in the hope that it will be useful, but
 * WITHOUT ANY WARRANTY; without even the implied warranties of
 * MERCHANTABILITY, SATISFACTORY QUALITY or FITNESS FOR A PARTICULAR
 * PURPOSE.  See the GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * version 3 along with this program.  If not, see
 * <http://www.gnu.org/licenses/>
 *
 * Authored by: Michael Terry <michael.terry@canonical.com>
 */

#include "AccountsServer.h"
#include "PropertiesServer.h"
#include <QDBusConnection>
#include <QDebug>

AccountsServer::AccountsServer(PropertiesServer* propServer, QObject *parent)
    : QObject(parent)
    , m_propServer(propServer)
{
}

QDBusObjectPath AccountsServer::FindUserByName(const QString &user)
{
    return QDBusObjectPath(QString("/%1").arg(user));
}

bool AccountsServer::AddUser(const QString &user)
{
    QString path(QString("/%1").arg(user));
    if (QDBusConnection::sessionBus().objectRegisteredAt(path) == m_propServer)
        return true;
    return QDBusConnection::sessionBus().registerObject(path, m_propServer);
}

bool AccountsServer::RemoveUser(const QString &user)
{
    QString path(QString("/%1").arg(user));
    if (QDBusConnection::sessionBus().objectRegisteredAt(path) != m_propServer)
        return false;
    QDBusConnection::sessionBus().unregisterObject(path);
    return true;
}
