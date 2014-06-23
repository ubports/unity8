/*
 * Copyright 2014 Canonical Ltd.
 *
 * This program is free software; you can redistribute it and/or modify
 * it under the terms of the GNU Lesser General Public License as published by
 * the Free Software Foundation; version 3.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
 * GNU Lesser General Public License for more details.
 *
 * You should have received a copy of the GNU Lesser General Public License
 * along with this program. If not, see <http://www.gnu.org/licenses/>.
 *
 * Authors: Nick Dedekind <nick.dedekind@canonical.com>
*/

#ifndef URLDISPATCHER_H
#define URLDISPATCHER_H

#include <QObject>

/**
 * @brief The URLDispatcher class
 *
 * This class exposes the url-dispatcher glib API to QML.
 */

class URLDispatcher: public QObject
{
    Q_OBJECT
public:
    URLDispatcher(QObject *parent = 0);

    Q_INVOKABLE void send(QByteArray const& url);

Q_SIGNALS:
    void urlDispatched(QByteArray const& url, bool success);
};

#endif
