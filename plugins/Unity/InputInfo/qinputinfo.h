/****************************************************************************
**
** Copyright (C) 2014 Canonical, Ltd. and/or its subsidiary(-ies).
** Contact: http://www.qt-project.org/legal
**
** This file is part of the QtSystems module of the Qt Toolkit.
**
** $QT_BEGIN_LICENSE:LGPL$
** Commercial License Usage
** Licensees holding valid commercial Qt licenses may use this file in
** accordance with the commercial license agreement provided with the
** Software or, alternatively, in accordance with the terms contained in
** a written agreement between you and Digia.  For licensing terms and
** conditions see http://qt.digia.com/licensing.  For further information
** use the contact form at http://qt.digia.com/contact-us.
**
** GNU Lesser General Public License Usage
** Alternatively, this file may be used under the terms of the GNU Lesser
** General Public License version 2.1 as published by the Free Software
** Foundation and appearing in the file LICENSE.LGPL included in the
** packaging of this file.  Please review the following information to
** ensure the GNU Lesser General Public License version 2.1 requirements
** will be met: http://www.gnu.org/licenses/old-licenses/lgpl-2.1.html.
**
** In addition, as a special exception, Digia gives you certain additional
** rights.  These rights are described in the Digia Qt LGPL Exception
** version 1.1, included in the file LGPL_EXCEPTION.txt in this package.
**
** GNU General Public License Usage
** Alternatively, this file may be used under the terms of the GNU
** General Public License version 3.0 as published by the Free Software
** Foundation and appearing in the file LICENSE.GPL included in the
** packaging of this file.  Please review the following information to
** ensure the GNU General Public License version 3.0 requirements will be
** met: http://www.gnu.org/copyleft/gpl.html.
**
**
** $QT_END_LICENSE$
**
****************************************************************************/

#ifndef QINPUTINFO_H
#define QINPUTINFO_H

#include <QObject>
#include <QVector>
#include <QMap>
#include <QSocketNotifier>
#include <QDebug>

class QInputDeviceManagerPrivate;
class QInputDevicePrivate;
class QInputDevice;

class QInputDeviceManager;

class QInputDevice : public QObject
{
    Q_OBJECT
    Q_ENUMS(InputType)
    Q_FLAGS(InputType InputTypeFlags)
    friend class QInputDeviceManagerPrivate;

public:

    enum InputType {
        Unknown = 0,
        Button = 1,
        Mouse = 2,
        TouchPad = 4,
        TouchScreen = 8,
        Keyboard = 16,
        Switch = 32
    };
    Q_ENUMS(InputType)
    Q_DECLARE_FLAGS(InputTypeFlags, InputType)

    explicit QInputDevice(QObject *parent = 0);
    QString name() const;
    QString devicePath() const;
    QList <int> buttons() const; //keys event code
    QList <int> switches() const;
    QList <int> relativeAxis() const;
    QList <int> absoluteAxis() const;
    QInputDevice::InputTypeFlags type() const;

private:

    QInputDevicePrivate *d_ptr;
    void setName(const QString &);
    void setDevicePath(const QString &);
    void addButton(int);
    void addSwitch(int);
    void addRelativeAxis(int);
    void addAbsoluteAxis(int);
    void setType(QInputDevice::InputTypeFlags flags);

};

Q_DECLARE_METATYPE(QInputDevice::InputType)
Q_DECLARE_METATYPE(QInputDevice::InputTypeFlags)

class QInputDeviceManagerPrivate;

class QInputDeviceManager : public QObject
{
    Q_OBJECT
    Q_PROPERTY(int deviceCount READ deviceCount NOTIFY deviceCountChanged)
    Q_PROPERTY(QInputDevice::InputType deviceFilter READ deviceFilter WRITE setDeviceFilter NOTIFY deviceFilterChanged)
public:

    explicit QInputDeviceManager(QObject *parent = 0);

    int deviceCount() const;
    int deviceCount(const QInputDevice::InputType filter) const;

    void setDeviceFilter(QInputDevice::InputType filter);
    QInputDevice::InputType deviceFilter();

    QMap <QString, QInputDevice *> deviceMap();
    Q_INVOKABLE QVector <QInputDevice *> deviceListOfType(QInputDevice::InputType filter);

Q_SIGNALS:

    void deviceAdded(const QString & devicePath);
    void deviceRemoved(const QString & devicePath);

    void ready();
    void deviceCountChanged(int count);
    void deviceFilterChanged(const QInputDevice::InputType filter);

public Q_SLOTS:
    void addedDevice(const QString & devicePath);

private:
    Q_DISABLE_COPY(QInputDeviceManager)
#if !defined(QT_SIMULATOR)
    QInputDeviceManagerPrivate *const d_ptr;
    Q_DECLARE_PRIVATE(QInputDeviceManager)
#endif
};

#endif // QINPUTINFO_H
