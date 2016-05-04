/*
 * Copyright (C) 2013 Canonical, Ltd.
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

#ifndef UNITY_SESSIONBROADCAST_H
#define UNITY_SESSIONBROADCAST_H

#include <QObject>
#include <QString>

class QDBusInterface;

class SessionBroadcast: public QObject
{
    Q_OBJECT

public:
    explicit SessionBroadcast(QObject *parent = 0);

Q_SIGNALS:
    void showHome();

private Q_SLOTS:
    void onShowHome(const QString &username);

private:
    QString m_username;
};

#endif
