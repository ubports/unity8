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

#include "mockqinputinfo.h"


QInputDevice::QInputDevice(QObject *parent) :
    QObject(parent)
{
}

QString QInputDevice::name() const
{
    return m_name;
}

void QInputDevice::setName(const QString &name)
{
    m_name = name;
}

QString QInputDevice::devicePath() const
{
    return m_devicePath;
}

void QInputDevice::setDevicePath(const QString &path)
{
    m_devicePath = path;
}

QList <int> QInputDevice::buttons() const
{
    return {1, 2 ,3};
}

QList <int> QInputDevice::switches() const
{
    return {};
}

QList <int> QInputDevice::relativeAxis() const
{
    return {};
}

QList <int> QInputDevice::absoluteAxis() const
{
    return {};
}

QInputDeviceInfo::InputTypes QInputDevice::types()
{
    return m_types;
}

void QInputDevice::setTypes(QInputDeviceInfo::InputTypes types)
{
    m_types = types;
}

QInputDeviceInfo::QInputDeviceInfo(QObject *parent) :
    QObject(parent)
{
}

QVector <QInputDevice *> QInputDeviceInfo::deviceList()
{
    return m_list;
}

void QInputDeviceInfo::removeMockDevice(int index)
{
    QInputDevice *device = m_list.takeAt(index);
    Q_EMIT deviceRemoved(device->devicePath());
    device->deleteLater();
}

void QInputDeviceInfo::addMockDevice(QInputDeviceInfo::InputType inputType)
{
    QInputDevice *device = new QInputDevice(this);
    device->setDevicePath("/mock/device/" + QString::number(m_counter++));
    device->setTypes({inputType});
    m_list.append(device);
    Q_EMIT deviceAdded(device->devicePath());
}
