/*
 * Copyright (C) 2013,2016 Canonical, Ltd.
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

    Q_INVOKABLE void requestUrlStart(const QString &username, const QString &url);
    Q_INVOKABLE void requestHomeShown(const QString &username);

Q_SIGNALS:
    // This signal isn't actually used by the shell
    // (unity-greeter-session-broadcast handles launching an app for us), but
    // it's useful for testing the plugin.
    void startUrl(const QString &url);
    void showHome();

private Q_SLOTS:
    void onStartUrl(const QString &username, const QString &url);
    void onShowHome(const QString &username);

private:
    QString m_username;
    QDBusInterface *m_broadcaster;
};

#endif
