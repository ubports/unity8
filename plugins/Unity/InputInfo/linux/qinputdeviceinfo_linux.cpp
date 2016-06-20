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

#include "qinputdeviceinfo_linux_p.h"

#include <libudev.h>
#include <libevdev/libevdev.h>
#include <fcntl.h>
#include <unistd.h>
#include <QDebug>
#include <QSocketNotifier>
#include <QTimer>
#include <QDir>

QInputDeviceManagerPrivate::QInputDeviceManagerPrivate(QObject *parent) :
    QObject(parent),
    currentFilter(QInputDevice::Unknown),
    udevMonitor(0),
    udevice(0)
{
    QTimer::singleShot(250,this,SLOT(init()));
}

QInputDeviceManagerPrivate::~QInputDeviceManagerPrivate()
{
    udev_unref(udevice);
    udev_monitor_unref(udevMonitor);
}

void QInputDeviceManagerPrivate::init()
{
    if (!udevice)
        udevice = udev_new();

    udev_list_entry *devices;
    udev_list_entry *dev_list_entry;
    udev_device *dev;

    QString subsystem = QStringLiteral("input");
    struct udev_enumerate *enumerate = 0;

    if (udevice) {

        udevMonitor = udev_monitor_new_from_netlink(udevice, "udev");
        udev_monitor_filter_add_match_subsystem_devtype(udevMonitor, subsystem.toLatin1(), NULL);
        enumerate = udev_enumerate_new(udevice);
        udev_enumerate_add_match_subsystem(enumerate, subsystem.toLatin1());

        udev_monitor_enable_receiving(udevMonitor);
        int notifierFd = udev_monitor_get_fd(udevMonitor);

        QSocketNotifier *notifier = new QSocketNotifier(notifierFd, QSocketNotifier::Read, this);
        connect(notifier, SIGNAL(activated(int)), this, SLOT(onUDevChanges()));

        udev_enumerate_scan_devices(enumerate);
        devices = udev_enumerate_get_list_entry(enumerate);

        udev_list_entry_foreach(dev_list_entry, devices) {
            const char *path;
            path = udev_list_entry_get_name(dev_list_entry);

            dev = udev_device_new_from_syspath(udevice, path);
            if (qstrcmp(udev_device_get_subsystem(dev), "input") == 0 ) {
                QInputDevice *iDevice = addDevice(dev);
                if (iDevice && !iDevice->devicePath().isEmpty()) {
                    deviceMap.insert(iDevice->devicePath(),iDevice);
                }
            }
            udev_device_unref(dev);
        }
        udev_enumerate_unref(enumerate);
    }
 //   udev_unref(udevice);
    Q_FOREACH (const QString &devicePath, deviceMap.keys()) {
        Q_EMIT deviceAdded(devicePath);
    }
    Q_EMIT ready();
}

QInputDevice::InputTypeFlags QInputDeviceManagerPrivate::getInputTypeFlags(struct udev_device *dev)
{
    QInputDevice::InputTypeFlags flags = QInputDevice::Unknown;
    if (qstrcmp(udev_device_get_property_value(dev, "ID_INPUT_KEY"), "1") == 0 ) {
        flags |= QInputDevice::Button;
    }
    if (qstrcmp(udev_device_get_property_value(dev, "ID_INPUT_MOUSE"), "1") == 0) {
        flags |= QInputDevice::Mouse;
    }
    if (qstrcmp(udev_device_get_property_value(dev, "ID_INPUT_TOUCHPAD"), "1") == 0) {
        flags |= QInputDevice::TouchPad;
    }
    if (qstrcmp(udev_device_get_property_value(dev, "ID_INPUT_TOUCHSCREEN"), "1") == 0
            || qstrcmp(udev_device_get_property_value(dev, "ID_INPUT_TABLET"), "1") == 0) {
        flags |= QInputDevice::TouchScreen;
    }
    if (qstrcmp(udev_device_get_property_value(dev, "ID_INPUT_KEYBOARD"), "1") == 0 ) {
        flags |= QInputDevice::Keyboard;
    }
    if (!QString::fromLatin1(udev_device_get_property_value(dev, "SW")).isEmpty()) {
        flags |= QInputDevice::Switch;
    }

    return flags;
}

QInputDevice *QInputDeviceManagerPrivate::addDevice(struct udev_device *udev)
{
    QString eventPath = QString::fromLatin1(udev_device_get_sysname(udev));

    if (eventPath.contains(QStringLiteral("event")))
        eventPath.prepend(QStringLiteral("/dev/input/"));

    if (deviceMap.contains(eventPath)) {
        return Q_NULLPTR;
    }
    struct libevdev *dev = NULL;
    int fd;
    int rc = 1;
    QInputDevice *inputDevice;
    inputDevice = addUdevDevice(udev);
    if (!inputDevice) {
        return Q_NULLPTR;
    }
    eventPath = inputDevice->devicePath();

    qDebug() << "Input device added:" << inputDevice->name() << inputDevice->devicePath() << inputDevice->type();

    fd = open(eventPath.toLatin1(), O_RDONLY|O_NONBLOCK);
    if (fd == -1) {
        return inputDevice;
    }
    rc = libevdev_new_from_fd(fd, &dev);
    if (rc < 0) {
        qWarning() << "Failed to init libevdev ("<< strerror(-rc) << ")";
        close(fd);
        return Q_NULLPTR;
    }

    for (int i = 0; i < EV_MAX; i++) {
        if (i == EV_KEY || i == EV_SW || i == EV_REL
                || i == EV_REL || i == EV_ABS) {
            for (int j = 0; j <  libevdev_event_type_get_max(i); j++) {
                if (libevdev_has_event_code(dev, i, j)) {
                    switch (i) {
                    case EV_KEY:
                        inputDevice->addButton(j);
                        break;
                    case EV_SW:
                        inputDevice->addSwitch(j);
                        break;
                    case EV_REL:
                        inputDevice->addRelativeAxis(j);
                        break;
                    case EV_ABS:
                        inputDevice->addAbsoluteAxis(j);
                        break;
                    };
                }
            }
        }
    }

    libevdev_free(dev);
    close(fd);
    return inputDevice;
}

void QInputDeviceManagerPrivate::addDetails(struct udev_device *)
{
}

void QInputDeviceManagerPrivate::removeDevice(const QString &path)
{
    // this path is not a full evdev path
    Q_FOREACH (const QString devicePath, deviceMap.keys()) {
        if (devicePath.contains(path)) {
            qDebug() << "Input device removed:" << deviceMap.value(devicePath)->name() << devicePath << deviceMap.value(devicePath)->type();
            deviceMap.remove(devicePath);
            Q_EMIT deviceRemoved(devicePath);
        }
    }
}

QInputDevice *QInputDeviceManagerPrivate::addUdevDevice(struct udev_device *udev)
{
    QInputDevice *iDevice;

    struct udev_list_entry *list;
    struct udev_list_entry *node;

    list = udev_device_get_properties_list_entry (udev);
    QString syspath = QString::fromLatin1(udev_device_get_syspath(udev));
    QDir sysdir(syspath);

    QStringList infoList = sysdir.entryList(QStringList() << QStringLiteral("event*"),QDir::Dirs);

    if (infoList.count() > 0) {
        QString token = infoList.at(0);

        token.prepend(QStringLiteral("/dev/input/"));
        iDevice = new QInputDevice(this);
        iDevice->setDevicePath(token);
    } else {
        return Q_NULLPTR;
    }
    udev_list_entry_foreach (node, list) {

        QString key = QString::fromLatin1(udev_list_entry_get_name(node));
        QString value = QString::fromLatin1(udev_list_entry_get_value(node));

        if (key == QStringLiteral("NAME")) {
            iDevice->setName(value.remove(QStringLiteral("\"")));
        }
    }
    iDevice->setType(getInputTypeFlags(udev));
    return iDevice;
}

void QInputDeviceManagerPrivate::onUDevChanges()
{
    if (!udevMonitor)
        return;

    udev_device *dev = udev_monitor_receive_device(udevMonitor);

    if (dev) {
        if (qstrcmp(udev_device_get_subsystem(dev), "input") == 0 ) {
            QString eventPath = QString::fromLatin1(udev_device_get_sysname(dev));

            QString action = QString::fromStdString(udev_device_get_action(dev));

            if (!eventPath.contains(QStringLiteral("/dev/input/")))
                eventPath.prepend(QStringLiteral("/dev/input/"));

            if (action == QStringLiteral("add")) {
                if (deviceMap.contains(eventPath)){
                    udev_device_unref(dev);
                    return;
                }

                QInputDevice *iDevice = addDevice(dev);
                if (!iDevice) {
                    delete iDevice;
                    return;
                }
                iDevice->setType(getInputTypeFlags(dev));
                udev_device_unref(dev);

                deviceMap.insert(eventPath,iDevice);

                Q_EMIT deviceAdded(eventPath);

            } else if (action == QStringLiteral("remove")) {
                removeDevice(eventPath);
            }
        }
    }
}
