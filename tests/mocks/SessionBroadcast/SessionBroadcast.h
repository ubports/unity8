/*
 * Copyright (C) 2012,2013 Canonical, Ltd.
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
 * Authors: Michael Terry <michael.terry@canonical.com>
 */

#ifndef UNITY_MOCK_SESSIONBROADCAST_H
#define UNITY_MOCK_SESSIONBROADCAST_H

#include <QObject>

class SessionBroadcast: public QObject
{
    Q_OBJECT

public:
    explicit SessionBroadcast(QObject *parent = 0);

    Q_INVOKABLE void requestUrlStart(const QString &username, const QString &url);
    Q_INVOKABLE void requestHomeShown(const QString &username);

Q_SIGNALS:
    void startUrl(const QString &url);
    void showHome();
};

#endif
