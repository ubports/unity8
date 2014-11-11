/*
 * This file is part of system-settings
 *
 * Copyright (C) 2014 Canonical Ltd.
 *
 * This program is free software: you can redistribute it and/or modify it
 * under the terms of the GNU General Public License version 3, as published
 * by the Free Software Foundation.
 *
 * This program is distributed in the hope that it will be useful, but
 * WITHOUT ANY WARRANTY; without even the implied warranties of
 * MERCHANTABILITY, SATISFACTORY QUALITY, or FITNESS FOR A PARTICULAR
 * PURPOSE.  See the GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License along
 * with this program.  If not, see <http://www.gnu.org/licenses/>.
 */

#include "system.h"
#include <QDBusInterface>
#include <QDBusPendingCall>
#include <QDBusPendingReply>
#include <QFile>
#include <QProcess>
#include <unistd.h>

#define HERE_IFACE   "com.ubuntu.location.providers.here.AccountsService"
#define ENABLED_PROP "LicenseAccepted"
#define PATH_PROP    "LicenseBasePath"

System::System()
    : QObject(),
      m_accounts(nullptr),
      m_hereEnabled(false),
      m_hereLicensePath(" ") // use a single space to indicate it is unasssigned
{
    m_accounts = new QDBusInterface("org.freedesktop.Accounts",
                                    "/org/freedesktop/Accounts/User" + QString::number(geteuid()),
                                    "org.freedesktop.DBus.Properties",
                                    QDBusConnection::systemBus(),
                                    this);

    m_accounts->connection().connect(m_accounts->service(),
                                     m_accounts->path(),
                                     m_accounts->interface(),
                                     "PropertiesChanged",
                                     this,
                                     SLOT(propertiesChanged(QString, QVariantMap, QStringList)));

    QDBusPendingCall call = m_accounts->asyncCall("Get", HERE_IFACE, PATH_PROP);
    QDBusPendingCallWatcher *watcher = new QDBusPendingCallWatcher(call, this);
    QObject::connect(watcher, SIGNAL(finished(QDBusPendingCallWatcher *)),
                     this, SLOT(getHereLicensePathFinished(QDBusPendingCallWatcher *)));
}

void System::propertiesChanged(const QString &interface, const QVariantMap &changed, const QStringList &invalid)
{
    if (interface == HERE_IFACE) {
        if (changed.contains(ENABLED_PROP)) {
            m_hereEnabled = changed[ENABLED_PROP].toBool();
            Q_EMIT hereEnabledChanged();
        } else if (invalid.contains(ENABLED_PROP)) {
            QDBusPendingCall call = m_accounts->asyncCall("Get", HERE_IFACE, ENABLED_PROP);
            QDBusPendingCallWatcher *watcher = new QDBusPendingCallWatcher(call, this);
            QObject::connect(watcher, SIGNAL(finished(QDBusPendingCallWatcher *)),
                             this, SLOT(getHereEnabledFinished(QDBusPendingCallWatcher *)));
        }
    }
}

void System::getHereEnabledFinished(QDBusPendingCallWatcher *watcher)
{
    QDBusPendingReply<QVariant> reply = *watcher;
    if (!reply.isError()) {
        QVariant value = reply.argumentAt<0>();
        m_hereEnabled = value.toBool();
        Q_EMIT hereEnabledChanged();
    }
    watcher->deleteLater();
}

void System::getHereLicensePathFinished(QDBusPendingCallWatcher *watcher)
{
    QDBusPendingReply<QVariant> reply = *watcher;

    m_hereLicensePath = "";

    if (!reply.isError()) {
        QVariant value = reply.argumentAt<0>();
        if (QFile::exists(value.toString())) {
            m_hereLicensePath = value.toString();
        }
    }

    Q_EMIT hereLicensePathChanged();

    watcher->deleteLater();
}

bool System::hereEnabled() const
{
    return m_hereEnabled;
}

void System::setHereEnabled(bool enabled)
{
    m_accounts->asyncCall("Set", HERE_IFACE, ENABLED_PROP, QVariant::fromValue(QDBusVariant(enabled)));
}

QString System::hereLicensePath() const
{
    return m_hereLicensePath;
}

void System::updateSessionLanguage()
{
    QProcess::startDetached("sh -c \"initctl start ubuntu-system-settings-wizard-set-lang; initctl emit --no-wait indicator-services-start; initctl start --no-wait maliit-server\"");
}
