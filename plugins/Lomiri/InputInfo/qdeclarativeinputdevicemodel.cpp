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
#include "qdeclarativeinputdevicemodel_p.h"
#include "qinputinfo.h"

QDeclarativeInputDeviceModel::QDeclarativeInputDeviceModel(QObject *parent) :
    QAbstractListModel(parent),
    deviceInfo(new QInputDeviceManager),
    currentFilter(QInputDevice::Unknown)
{
    connect(deviceInfo,SIGNAL(ready()),this,SLOT(updateDeviceList()));
    connect(deviceInfo, &QInputDeviceManager::deviceAdded,this,&QDeclarativeInputDeviceModel::addedDevice);
    connect(deviceInfo, &QInputDeviceManager::deviceRemoved,this,&QDeclarativeInputDeviceModel::removedDevice);
}

QDeclarativeInputDeviceModel::~QDeclarativeInputDeviceModel()
{
    delete deviceInfo;
}

QVariant QDeclarativeInputDeviceModel::data(const QModelIndex &index, int role) const
{
    switch (role) {
    case ServiceRole:
        return QVariant::fromValue(static_cast<QObject *>(inputDevices.value(index.row())));
        break;
    case NameRole:
        return QVariant::fromValue(static_cast<QString>(inputDevices.value(index.row())->name()));
        break;
    case DevicePathRole:
        return QVariant::fromValue(static_cast<QString>(inputDevices.value(index.row())->devicePath()));
        break;
    case ButtonsRole:
        return QVariant::fromValue(static_cast<QList <int> >(inputDevices.value(index.row())->buttons()));
        break;
    case SwitchesRole:
        return QVariant::fromValue(static_cast<QList <int> >(inputDevices.value(index.row())->switches()));
        break;
    case RelativeAxisRole:
        return QVariant::fromValue(static_cast<QList <int> >(inputDevices.value(index.row())->relativeAxis()));
        break;
    case AbsoluteAxisRole:
        return QVariant::fromValue(static_cast<QList <int> >(inputDevices.value(index.row())->absoluteAxis()));
        break;
    case TypesRole:
        return QVariant::fromValue(static_cast<int>(inputDevices.value(index.row())->type()));
        break;
    };

    return QVariant();
}

int QDeclarativeInputDeviceModel::rowCount(const QModelIndex &parent) const
{
    Q_UNUSED(parent);

    return inputDevices.count();
}

int QDeclarativeInputDeviceModel::indexOf(const QString &devicePath) const
{
    int idx(-1);
    Q_FOREACH (QInputDevice *device, inputDevices) {
        idx++;
        if (device->devicePath() == devicePath) return idx;
    }

    return -1;
}

QInputDevice *QDeclarativeInputDeviceModel::get(int index) const
{
    if (index < 0 || index > inputDevices.count())
        return 0;
    return inputDevices.value(index);
}

void QDeclarativeInputDeviceModel::updateDeviceList()
{
    QVector <QInputDevice *> newDevices = deviceInfo->deviceListOfType(currentFilter);

    int numNew = newDevices.count();

    for (int i = 0; i < numNew; i++) {
        int j = inputDevices.indexOf(newDevices.value(i));

        if (j == -1) {
            beginInsertRows(QModelIndex(), i, i);
            inputDevices.insert(i, newDevices.value(i));
            endInsertRows();
            Q_EMIT countChanged();
        } else if (i != j) {
            // changed its position -> move it
            QInputDevice* device = inputDevices.value(j);
            beginMoveRows(QModelIndex(), j, j, QModelIndex(), i);
            inputDevices.remove(j);
            inputDevices.insert(i, device);
            endMoveRows();
            Q_EMIT countChanged();
        } //else {
        QModelIndex changedIndex(this->index(j, 0, QModelIndex()));
        Q_EMIT dataChanged(changedIndex, changedIndex);
    }

    int numOld = inputDevices.count();
    if (numOld > numNew) {
        beginRemoveRows(QModelIndex(), numNew, numOld - 1);
        inputDevices.remove(numNew, numOld - numNew);
        endRemoveRows();
        Q_EMIT countChanged();
    }
}

void QDeclarativeInputDeviceModel::addedDevice(const QString &devicePath)
{
    updateDeviceList();
    Q_EMIT deviceAdded(devicePath);
}

void QDeclarativeInputDeviceModel::removedDevice(const QString &devicePath)
{
    updateDeviceList();
    Q_EMIT deviceRemoved(devicePath);
}

QHash<int,QByteArray> QDeclarativeInputDeviceModel::roleNames() const
{
    QHash<int, QByteArray> roles;
    roles[NameRole] = "name";
    roles[DevicePathRole] = "devicePath";
    roles[ButtonsRole] = "buttons";
    roles[SwitchesRole] = "switches";
    roles[RelativeAxisRole] = "rAxis";
    roles[AbsoluteAxisRole] = "aAxis";
    roles[TypesRole] = "types";
    return roles;
}

/*
 * Returns the currently set device filter.
 * */
QInputDevice::InputType QDeclarativeInputDeviceModel::deviceFilter()
{
    return currentFilter;
}

/*
 * Sets the current  input device filter to filter.
 * */
void QDeclarativeInputDeviceModel::setDeviceFilter(QInputDevice::InputType filter)
{
    if (filter != currentFilter) {
        deviceInfo->setDeviceFilter(filter);
        currentFilter = filter;
        updateDeviceList();
        Q_EMIT deviceFilterChanged(filter);
    }
}
