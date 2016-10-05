/*
 * Copyright 2016 Canonical Ltd.
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
 */

#include "BroadcastServer.h"

BroadcastServer::BroadcastServer(QObject *parent)
    : QObject(parent)
{
}

void BroadcastServer::RequestUrlStart(const QString &username, const QString &url)
{
    Q_EMIT StartUrl(username, url);
}

void BroadcastServer::RequestHomeShown(const QString &username)
{
    Q_EMIT ShowHome(username);
}
