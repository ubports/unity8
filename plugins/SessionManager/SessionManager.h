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
 * Authors: Gerry Boland <gerry.boland@canonical.com>
 *          Michael Terry <michael.terry@canonical.com>
 */

#ifndef UNITY_SESSIONMANAGER_H
#define UNITY_SESSIONMANAGER_H

#include <QtCore/QObject>
#include <QtCore/QString>
#include <QtCore/QStringList>
#include <QtCore/QVariantMap>
#include <QtDBus/QDBusInterface>
#include <QtDBus/QDBusPendingCallWatcher>

class SessionManager: public QObject
{
    Q_OBJECT
    Q_PROPERTY(bool active
               READ active
               NOTIFY activeChanged
               FINAL)

public:
    explicit SessionManager(QObject *parent = 0);

    bool active() const;

public Q_SLOTS:
    void lock();

Q_SIGNALS:
    void activeChanged();

private Q_SLOTS:
    void getSessionSlot(QDBusPendingCallWatcher *watcher);
    void propertiesChanged(const QString &interface, const QVariantMap &changed, const QStringList &invalid);
    void sessionLocked();

private:
    QDBusInterface *l1_manager;
    QDBusInterface *l1_session;
    QDBusInterface *ldm_session;
    bool is_active;
};

#endif
