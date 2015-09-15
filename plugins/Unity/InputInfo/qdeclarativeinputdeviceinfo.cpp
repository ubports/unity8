/****************************************************************************
**
** Copyright (C) 2015 Jolla.
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
#include "qdeclarativeinputdeviceinfo_p.h"

QDeclarativeInputDeviceInfo::QDeclarativeInputDeviceInfo(QObject *parent) :
    QAbstractListModel(parent),
    deviceInfo(new QInputDeviceInfo)
{
    connect(deviceInfo, &QInputDeviceInfo::ready, this, &QDeclarativeInputDeviceInfo::updateDeviceList);
    connect(deviceInfo, &QInputDeviceInfo::deviceAdded,this,&QDeclarativeInputDeviceInfo::addedDevice);
    connect(deviceInfo, &QInputDeviceInfo::deviceRemoved,this,&QDeclarativeInputDeviceInfo::removedDevice);
}

QDeclarativeInputDeviceInfo::~QDeclarativeInputDeviceInfo()
{
    delete deviceInfo;
}

QVariant QDeclarativeInputDeviceInfo::data(const QModelIndex &index, int role) const
{
    switch (role) {
    case ServiceRole:
        return QVariant::fromValue(static_cast<QObject *>(inputDevices.value(index.row())));
    }

    return QVariant();
}

int QDeclarativeInputDeviceInfo::rowCount(const QModelIndex &parent) const
{
    Q_UNUSED(parent);

    return inputDevices.count();
}

int QDeclarativeInputDeviceInfo::indexOf(const QString &devicePath) const
{
    int idx(-1);
    Q_FOREACH (QInputDevice *device, inputDevices) {
        idx++;
        if (device->devicePath() == devicePath) return idx;
    }

    return -1;
}

QInputDevice *QDeclarativeInputDeviceInfo::get(int index) const
{
    if (index < 0 || index > inputDevices.count())
        return 0;
    return inputDevices.value(index);
}

void QDeclarativeInputDeviceInfo::updateDeviceList()
{
   QVector <QInputDevice *> newDevices = deviceInfo->deviceList();

    int numNew = newDevices.count();

    for (int i = 0; i < numNew; i++) {
        int j = inputDevices.indexOf(newDevices.value(i));
        if (j == -1) {
            // not found -> remove from list
            beginInsertRows(QModelIndex(), i, i);
            inputDevices.insert(i, newDevices.value(i));
            endInsertRows();
        } else if (i != j) {
            // changed its position -> move it
            QInputDevice* device = inputDevices.value(j);
            beginMoveRows(QModelIndex(), j, j, QModelIndex(), i);
            inputDevices.remove(j);
            inputDevices.insert(i, device);
            endMoveRows();
        } else {
            QModelIndex changedIndex(this->index(j, 0, QModelIndex()));
            Q_EMIT dataChanged(changedIndex, changedIndex);
        }
    }

    int numOld = inputDevices.count();
    if (numOld > numNew) {
        beginRemoveRows(QModelIndex(), numNew, numOld - 1);
        inputDevices.remove(numNew, numOld - numNew);
        endRemoveRows();
    }
}

void QDeclarativeInputDeviceInfo::addedDevice(const QString &devicePath)
{
    updateDeviceList();
    Q_EMIT newDevice(devicePath);
}

void QDeclarativeInputDeviceInfo::removedDevice(const QString &devicePath)
{
    updateDeviceList();
    Q_EMIT deviceRemoved(devicePath);
}

QHash<int, QByteArray> QDeclarativeInputDeviceInfo::roleNames() const
{
    QHash<int, QByteArray> roles;
    roles.insert(ServiceRole, "service");
    return roles;
}
