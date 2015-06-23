/****************************************************************************
**
** Copyright (C) 2015 Canonical, Ltd. and/or its subsidiary(-ies).
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

#ifndef MOCKQINPUTINFO_H
#define MOCKQINPUTINFO_H

#include <QObject>
#include <QVector>
#include <QMap>
#include <QSocketNotifier>
#include <QDebug>

class QInputDevicePrivate;
class QInputDevice;

class QInputDeviceInfoPrivate;
class QInputDeviceInfo : public QObject
{
    Q_OBJECT
    Q_PROPERTY(int deviceCount READ deviceCount)
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
    Q_FLAGS(InputTypes)
    Q_DECLARE_FLAGS(InputTypes, InputType)

    explicit QInputDeviceInfo(QObject *parent = 0);

    Q_INVOKABLE QVector <QInputDevice *> deviceList();

    int deviceCount() { return deviceList().count(); }

    Q_INVOKABLE void addMockDevice(InputType inputType);
    Q_INVOKABLE void removeMockDevice(int index);

Q_SIGNALS:

    void deviceAdded(const QString & devicePath);
    void deviceRemoved(const QString & devicePath);

private:
    QVector<QInputDevice*> m_list;

    int m_counter = 0;
};

class QInputDevice : public QObject
{
    friend class QInputDeviceInfoPrivate;
    Q_OBJECT
    Q_ENUMS(InputType)
    Q_FLAGS(InputTypes)
    Q_PROPERTY(QString name READ name NOTIFY nameChanged)
    Q_PROPERTY(QString devicePath READ devicePath NOTIFY devicePathChanged)
    Q_PROPERTY(QList <int> buttons READ buttons NOTIFY buttonsChanged)
    Q_PROPERTY(QList <int> switches READ switches NOTIFY switchesChanged)
    Q_PROPERTY(QList <int> relativeAxis READ relativeAxis NOTIFY relativeAxisChanged)
    Q_PROPERTY(QList <int> absoluteAxis READ absoluteAxis NOTIFY absoluteAxisChanged)
    Q_PROPERTY(QInputDeviceInfo::InputTypes types READ types NOTIFY typesChanged)

public:
    explicit QInputDevice(QObject *parent = 0);

    QString name() const;
    QString devicePath() const;
    QList <int> buttons() const; //keys event code
    QList <int> switches() const;
    QList <int> relativeAxis() const;
    QList <int> absoluteAxis() const;

    QInputDeviceInfo::InputTypes types();
Q_SIGNALS:
    void nameChanged();
    void devicePathChanged();
    void buttonsChanged();
    void switchesChanged();
    void relativeAxisChanged();
    void absoluteAxisChanged();
    void typesChanged();
private:
    void setName(const QString &name);
    void setTypes(QInputDeviceInfo::InputTypes types);
    void setDevicePath(const QString &path);

    QString m_name;
    QInputDeviceInfo::InputTypes m_types;
    QString m_devicePath;

    friend class QInputDeviceInfo;
};

#endif // MOCKQINPUTINFO_H
