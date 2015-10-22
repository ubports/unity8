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
