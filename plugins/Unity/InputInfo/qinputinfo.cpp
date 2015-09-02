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

#include "qinputinfo.h"

#if defined(Q_OS_LINUX)
#include "linux/qinputdeviceinfo_linux_p.h"
#endif

QT_BEGIN_NAMESPACE


QInputDevicePrivate::QInputDevicePrivate(QObject *parent) :
    QObject(parent),
    types(QInputDeviceInfo::Unknown)
{
}

QInputDevice::QInputDevice(QObject *parent) :
    QObject(parent),
    d_ptr(new QInputDevicePrivate(this))
{
}

QString QInputDevice::name() const
{
    return d_ptr->name;
}

void QInputDevice::setName(const QString &name)
{
    d_ptr->name = name;
}

QString QInputDevice::devicePath() const
{
    return d_ptr->devicePath;
}

void QInputDevice::setDevicePath(const QString &path)
{
    d_ptr->devicePath = path;
}

QList <int> QInputDevice::buttons() const
{
    return d_ptr->buttons;
}

void QInputDevice::addButton(int buttonCode)
{
    d_ptr->buttons.append(buttonCode);
}

QList <int> QInputDevice::switches() const
{
    return d_ptr->switches;
}

void QInputDevice::addSwitch(int switchCode)
{
    d_ptr->switches.append(switchCode);
}

QList <int> QInputDevice::relativeAxis() const
{
    return d_ptr->relativeAxis;
}

void QInputDevice::addRelativeAxis(int axisCode)
{
    d_ptr->relativeAxis.append(axisCode);
}

QList <int> QInputDevice::absoluteAxis() const
{
    return d_ptr->absoluteAxis;
}

void QInputDevice::addAbsoluteAxis(int axisCode)
{
    d_ptr->absoluteAxis.append(axisCode);
}

QInputDeviceInfo::InputTypes QInputDevice::types()
{
    return d_ptr->types;
}

void QInputDevice::setTypes(QInputDeviceInfo::InputTypes types)
{
    d_ptr->types = types;
}


QInputDeviceInfo::QInputDeviceInfo(QObject *parent) :
    QObject(parent),
    d_ptr(new QInputDeviceInfoPrivate(this))
{
    connect(d_ptr, &QInputDeviceInfoPrivate::newDevice,this,&QInputDeviceInfo::addedDevice);
    connect(d_ptr, &QInputDeviceInfoPrivate::deviceRemoved,this,&QInputDeviceInfo::deviceRemoved);

    connect(d_ptr, &QInputDeviceInfoPrivate::ready, this, &QInputDeviceInfo::ready);
}

QVector <QInputDevice *> QInputDeviceInfo::deviceList()
{
    return d_ptr->deviceList;
}

QMap <QString, QInputDevice *> QInputDeviceInfo::deviceMap()
{
    return d_ptr->deviceMap;
}

void QInputDeviceInfo::addedDevice(const QString & devicePath)
{
    Q_EMIT deviceAdded(devicePath);
}

QT_END_NAMESPACE
