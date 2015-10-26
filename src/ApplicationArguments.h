/*
 * Copyright (C) 2013,2015 Canonical, Ltd.
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
 */


#ifndef APPLICATION_ARGUMENTS_H
#define APPLICATION_ARGUMENTS_H

#include <QObject>
#include <QSize>
#include <QString>

class ApplicationArguments : public QObject
{
    Q_OBJECT
    Q_PROPERTY(QString deviceName READ deviceName NOTIFY deviceNameChanged)
    Q_PROPERTY(QString mode READ mode CONSTANT)
public:
    ApplicationArguments(QObject *parent = nullptr);

    void setDeviceName(const QString &deviceName) {
        if (deviceName != m_deviceName) {
            m_deviceName = deviceName;
            Q_EMIT deviceNameChanged(m_deviceName);
        }
    }
    QString deviceName() const { return m_deviceName; }

    void setMode(const QString &mode) { m_mode = mode; }
    QString mode() const { return m_mode; }

Q_SIGNALS:
    void deviceNameChanged(const QString&);

private:
    QString m_deviceName;
    QString m_mode;
};

#endif // APPLICATION_ARGUMENTS_H
