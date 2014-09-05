/*
 * Copyright (C) 2011-2014 Canonical, Ltd.
 *
 * Authors:
 *  Ugo Riboni <ugo.riboni@canonical.com>
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

#ifndef ABSTRACTDBUSSERVICEMONITOR_H
#define ABSTRACTDBUSSERVICEMONITOR_H

#include <QObject>
#include <QString>
#include <QDBusConnection>

class QDBusInterface;
class QDBusServiceWatcher;

class AbstractDBusServiceMonitor : public QObject
{
    Q_OBJECT
    Q_ENUMS(Bus)
    Q_PROPERTY(bool serviceAvailable READ serviceAvailable NOTIFY serviceAvailableChanged)

public:
    enum Bus {
        SessionBus,
        SystemBus,
    };

    explicit AbstractDBusServiceMonitor(const QString &service, const QString &path, const QString &interface,
                                        const Bus bus = SessionBus,
                                        QObject *parent = 0);
    ~AbstractDBusServiceMonitor();

    QDBusInterface* dbusInterface() const;

    bool serviceAvailable() const;

Q_SIGNALS:
    void serviceAvailableChanged(bool available);

private Q_SLOTS:
    void createInterface(const QString &service);
    void destroyInterface(const QString &service);

protected:
    const QString m_service;
    const QString m_path;
    const QString m_interface;
    QDBusServiceWatcher* m_watcher;
    QDBusInterface* m_dbusInterface;
};

#endif // ABSTRACTDBUSSERVICEMONITOR_H
