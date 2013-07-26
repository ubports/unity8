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

#ifndef UNITY_LOGINMANAGERSERVER_H
#define UNITY_LOGINMANAGERSERVER_H

#include <QtCore/QObject>
#include <QtDBus/QDBusObjectPath>

class LoginManagerServer: public QObject
{
    Q_OBJECT

public:
    explicit LoginManagerServer(QObject *parent = 0);

public Q_SLOTS:
    QDBusObjectPath GetSession(const QString &id);
};

#endif
