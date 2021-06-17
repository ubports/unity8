/*
 * Copyright (C) 2021 UBports Foundation.
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
 * Authors: Alberto Mardegan <mardy@users.sourceforge.net>
 */

#include "LocationWatcher.h"

#include "ProcessControl.h"

#include <QDBusConnection>
#include <QDebug>
#include <QStringList>
#include <QTimer>

namespace {
const QString locationServiceName = QStringLiteral("com.ubuntu.location.Service");
const QString locationObjectPath = QStringLiteral("/com/ubuntu/location/Service");
const QString propertiesInterface = QStringLiteral("org.freedesktop.DBus.Properties");
const QString methodPropertiesChanged = QStringLiteral("PropertiesChanged");
} // namespace

class LocationWatcherPrivate: public QObject
{
    Q_OBJECT

public:
    LocationWatcherPrivate(ProcessControl *processControl);

private Q_SLOTS:
    void onPropertiesChanged(const QString &interface,
                             const QVariantMap &changedProps,
                             const QStringList &invalidatedProps);

private:
    friend class LocationWatcher;
    ProcessControl *m_processControl;
    QDBusConnection m_connection;
    QStringList m_clientApplications;
};

LocationWatcherPrivate::LocationWatcherPrivate(ProcessControl *processControl):
    QObject(),
    m_processControl(processControl),
    m_connection(QDBusConnection::systemBus())
{
    m_connection.connect(locationServiceName,
                         locationObjectPath,
                         propertiesInterface,
                         methodPropertiesChanged,
                         this,
                         SLOT(onPropertiesChanged(QString,QVariantMap,QStringList)));
}

void LocationWatcherPrivate::onPropertiesChanged(const QString &interface,
                                                 const QVariantMap &changedProps,
                                                 const QStringList &invalidatedProps)
{
    Q_UNUSED(interface);
    Q_UNUSED(invalidatedProps);

    qDebug() << Q_FUNC_INFO << changedProps;
    const auto i = changedProps.find(QStringLiteral("ClientApplications"));
    if (i != changedProps.end()) {
        const QStringList appIds = i.value().toStringList();
        qDebug() << "Location clients changed:" << appIds;
        /* We need to strip off the version (app IDs are in the form
         * "<publisher>_<app-name>_<version>") */
        m_clientApplications.clear();
        for (const QString &appId: appIds) {
            QStringList parts = appId.split('_');
            QString versionLessAppId = parts.mid(0, 2).join('_');
            m_clientApplications.append(versionLessAppId);
        }
        m_processControl->setAwakenProcesses(m_clientApplications);
    }
}

LocationWatcher::LocationWatcher(ProcessControl *processControl):
    QObject(processControl),
    d_ptr(new LocationWatcherPrivate(processControl))
{
}

LocationWatcher::~LocationWatcher() = default;

#include "LocationWatcher.moc"
