/*
 * Copyright 2015 Canonical Ltd.
 *
 * This program is free software; you can redistribute it and/or modify
 * it under the terms of the GNU Lesser General Public License as published by
 * the Free Software Foundation; version 3.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU Lesser General Public License for more details.
 *
 * You should have received a copy of the GNU Lesser General Public License
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.
 */

#ifndef QINPUTDEVICEINFO_MOCK_H
#define QINPUTDEVICEINFO_MOCK_H

#include <QObject>
#include "qinputinfo.h"

class QInputDevicePrivate : public QObject
{
    Q_OBJECT
public:
    explicit QInputDevicePrivate(QObject *parent = 0);

    QString name;
    QString devicePath;
    QList <int> buttons; //keys
    QList <int> switches;
    QList <int> relativeAxis;
    QList <int> absoluteAxis;
    QInputDevice::InputTypeFlags type;
};

class QInputDeviceManagerPrivate : public QObject
{
    Q_OBJECT
public:
    explicit QInputDeviceManagerPrivate(QObject *parent = 0);
    ~QInputDeviceManagerPrivate();
    QVector <QInputDevice *> deviceList;
    QMap <QString, QInputDevice *> deviceMap;
    static QInputDeviceManagerPrivate * instance();
    QInputDevice::InputType currentFilter;

    Q_INVOKABLE QInputDevice* addMockDevice(const QString &devicePath, QInputDevice::InputType type);
    Q_INVOKABLE void removeDevice(const QString &devicePath);

Q_SIGNALS:
    void deviceAdded(const QString &);
    void deviceRemoved(const QString &);
    void ready();
};

#endif // QINPUTDEVICEINFO_MOCK_H
