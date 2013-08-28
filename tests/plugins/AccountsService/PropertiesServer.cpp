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

#include "PropertiesServer.h"

PropertiesServer::PropertiesServer(QObject *parent)
    : QObject(parent),
      edge_demo(true)
{
}

QDBusVariant PropertiesServer::Get(const QString &interface, const QString &property)
{
    if (interface == "com.canonical.unity.AccountsService" && property == "demo-edges") {
        return QDBusVariant(QVariant(edge_demo));
    } else {
        sendErrorReply(QDBusError::InvalidArgs, "Bad interface or property");
        return QDBusVariant(QVariant());
    }
}

void PropertiesServer::Set(const QString &interface, const QString &property, const QDBusVariant &variant)
{
    if (interface == "com.canonical.unity.AccountsService" && property == "demo-edges") {
        edge_demo = variant.variant().toBool();
    } else {
        sendErrorReply(QDBusError::InvalidArgs, "Bad interface or property");
    }
}
