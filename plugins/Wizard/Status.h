/*
 * Copyright (C) 2015 Canonical Ltd.
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

#ifndef WIZARD_STATUS_H
#define WIZARD_STATUS_H

#include <QObject>
#include <QString>
#include <QDBusInterface>

class Status: public QObject
{
    Q_OBJECT
    Q_PROPERTY(bool online READ online NOTIFY onlineChanged)
    Q_PROPERTY(QString networkIcon READ networkIcon NOTIFY networkIconChanged)
    Q_PROPERTY(QString batteryIcon READ batteryIcon NOTIFY batteryIconChanged)
public:
    Status();
    ~Status() = default;

    bool online() const;
    QString networkIcon();

    QString batteryIcon() const;

Q_SIGNALS:
    void networkIconChanged();
    void onlineChanged();
    void batteryIconChanged();

private Q_SLOTS:
    void onNMPropertiesChanged(const QVariantMap &changedProps);
    void onUPowerPropertiesChanged(const QString &iface, const QVariantMap &changedProps, const QStringList &invalidatedProps);

private:
    Q_DISABLE_COPY(Status)

    // network status
    void initNM();
    QDBusInterface * m_nmIface = nullptr;

    // battery status
    void initUPower();
    QDBusInterface * m_upowerIface = nullptr;
};

#endif
