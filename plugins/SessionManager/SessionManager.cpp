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
 * Author: Michael Terry <michael.terry@canonical.com>
 */

#include "SessionManager.h"
#include <QtCore/QEvent>
#include <QtDBus/QDBusPendingReply>

SessionManager::SessionManager(QObject* parent)
  : QObject(parent),
    l1_manager(NULL),
    l1_session(NULL),
    ldm_session(NULL),
    is_active(true) // assume we're active w/o logind
{
    l1_manager = new QDBusInterface("org.freedesktop.login1",
                                    "/org/freedesktop/login1",
                                    "org.freedesktop.login1.Manager",
                                    QDBusConnection::SM_BUSNAME(), this);
    if (l1_manager->isValid() && QString(qgetenv("XDG_SESSION_ID")) != "") {
        QDBusPendingCall pcall = l1_manager->asyncCall("GetSession", QString(qgetenv("XDG_SESSION_ID")));
        QDBusPendingCallWatcher *watcher = new QDBusPendingCallWatcher(pcall, this);
        QObject::connect(watcher, SIGNAL(finished(QDBusPendingCallWatcher*)),
                         this, SLOT(getSessionSlot(QDBusPendingCallWatcher*)));
    }

    if (QString(qgetenv("XDG_SESSION_PATH")) != "") {
        ldm_session = new QDBusInterface("org.freedesktop.DisplayManager",
                                         QString(qgetenv("XDG_SESSION_PATH")),
                                         "org.freedesktop.DisplayManager.Session",
                                         QDBusConnection::SM_BUSNAME(), this);
    }
}

bool SessionManager::active() const
{
    // We cache this value for performance reasons, as QDBusInterface does not
    // cache for us.
    return is_active;
}

void SessionManager::lock()
{
    // We use ldm_session to handle locking rather than l1_session, because
    // l1_session doesn't have permissions to lock from the user session, but
    // ldm_session does.  This is what the rest of Ubuntu uses to lock.
    if (ldm_session != NULL && ldm_session->isValid())
        ldm_session->asyncCall("Lock");
}

void SessionManager::getSessionSlot(QDBusPendingCallWatcher *watcher)
{
    QDBusPendingReply<QDBusObjectPath> reply = *watcher;
    if (!reply.isError()) {
        QDBusObjectPath path = reply.argumentAt<0>();
        l1_session = new QDBusInterface("org.freedesktop.login1",
                                        path.path(),
                                        "org.freedesktop.login1.Session",
                                        l1_manager->connection(), this);

        l1_manager->connection().connect("org.freedesktop.login1",
                                         path.path(),
                                         "org.freedesktop.DBus.Properties",
                                         "PropertiesChanged",
                                         this,
                                         SLOT(propertiesChanged(QString, QVariantMap, QStringList)));

        // Login1 is very odd about emitting PropertiesChanged.  It often does
        // not do so when active is becoming false.  But it always does when
        // it becomes true.  So we watch for the "Lock" signal too, which is a
        // reliably hint that active is false.
        l1_manager->connection().connect("org.freedesktop.login1",
                                         path.path(),
                                         "org.freedesktop.login1.Session",
                                         "Lock",
                                         this,
                                         SLOT(sessionLocked()));

        propertiesChanged("", QVariantMap(), QStringList() << "Active");
    }
    watcher->deleteLater();
}

void SessionManager::propertiesChanged(const QString &interface, const QVariantMap &changed, const QStringList &invalid)
{
    Q_UNUSED(interface)

    QVariant value = changed.value("Active");

    // If Active isn't in changed, check if we were at least notified about it
    // changing on the server.  Also check if IdleHint was modified, because
    // sometimes logind does not emit a changed signal for Active becoming
    // false, but will emit for IdleHint when that does happen.
    if (!value.isValid() && (invalid.contains("Active") || invalid.contains("IdleHint") || changed.contains("IdleHint")) && l1_session->isValid()) {
        value = l1_session->property("Active");
        if (!value.isValid())
            value = QVariant(false);
    }

    if (value.isValid() && value.toBool() != is_active) {
        is_active = value.toBool();
        Q_EMIT activeChanged();
    }
}

void SessionManager::sessionLocked()
{
    is_active = false;
    Q_EMIT activeChanged();
}
