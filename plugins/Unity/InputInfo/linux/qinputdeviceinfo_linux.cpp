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
#include <QDebug>
#include <QSocketNotifier>
#include <QTimer>

QInputDeviceInfoPrivate::QInputDeviceInfoPrivate(QObject *parent) :
    QObject(parent)
  , udev(0)
{
    QTimer::singleShot(250, this, &QInputDeviceInfoPrivate::init);
}

void QInputDeviceInfoPrivate::init()
{
    if (!udev)
        udev = udev_new();

    struct udev_list_entry *devices, *dev_list_entry;
    struct udev_device *dev;

    QString subsystem = QStringLiteral("input");
    struct udev_enumerate *enumerate = 0;

    if (udev) {

        udevMonitor = udev_monitor_new_from_netlink(udev, "udev");
        udev_monitor_filter_add_match_subsystem_devtype(udevMonitor, subsystem.toLatin1(), NULL);
        enumerate = udev_enumerate_new(udev);
        udev_enumerate_add_match_subsystem(enumerate, subsystem.toLatin1());


        udev_monitor_enable_receiving(udevMonitor);
        notifierFd = udev_monitor_get_fd(udevMonitor);

        notifier = new QSocketNotifier(notifierFd, QSocketNotifier::Read, this);
        connect(notifier, &QSocketNotifier::activated, this, &QInputDeviceInfoPrivate::onUDevChanges);


        udev_enumerate_scan_devices(enumerate);
        devices = udev_enumerate_get_list_entry(enumerate);

        udev_list_entry_foreach(dev_list_entry, devices) {
            const char *path;
            path = udev_list_entry_get_name(dev_list_entry);

            dev = udev_device_new_from_syspath(udev, path);

            QString eventPath = QString::fromLatin1(udev_device_get_sysname(dev));

            if (qstrcmp(udev_device_get_subsystem(dev), "input") == 0 ) {

                if (eventPath.contains(QStringLiteral("event"))) {
                    eventPath.prepend(QStringLiteral("/dev/input/"));

                    QInputDevice *iDevice = addDevice(eventPath);
                    if (!iDevice)
                        continue;

                    iDevice->setTypes(getInputTypes(dev));

                if (iDevice->switches().count() > 0 && iDevice->buttons().count() == 0)
                    iDevice->setTypes(iDevice->types() | QInputDeviceInfo::Switch);

                if (iDevice->buttons().count() > 0 && iDevice->types() == QInputDeviceInfo::Unknown)
                    iDevice->setTypes(iDevice->types() | QInputDeviceInfo::Button);

                deviceList.append(iDevice);
                deviceMap.insert(eventPath,iDevice);
                Q_EMIT newDevice(eventPath);

                }
            }
        }
        udev_enumerate_unref(enumerate);
    }
    Q_EMIT ready();
}

QInputDeviceInfo::InputTypes QInputDeviceInfoPrivate::getInputTypes( struct udev_device *dev)
{
    QInputDeviceInfo::InputTypes types = QInputDeviceInfo::Unknown;
    if (qstrcmp(udev_device_get_property_value(dev, "ID_INPUT_KEYBOARD"), "1") == 0 )
       types |= QInputDeviceInfo::Keyboard;

    if (qstrcmp(udev_device_get_property_value(dev, "ID_INPUT_MOUSE"), "1") == 0)
        types |= QInputDeviceInfo::Mouse;

    if (qstrcmp(udev_device_get_property_value(dev, "ID_INPUT_TOUCHPAD"), "1") == 0)
       types |= QInputDeviceInfo::TouchPad;

    if (qstrcmp(udev_device_get_property_value(dev, "ID_INPUT_TOUCHSCREEN"), "1") == 0
            || qstrcmp(udev_device_get_property_value(dev, "ID_INPUT_TABLET"), "1") == 0)
      types |= QInputDeviceInfo::TouchScreen;

    return types;
}

QInputDevice *QInputDeviceInfoPrivate::addDevice(const QString &path)
{
    QInputDevice *inputDevice = new QInputDevice(this);
    inputDevice->setDevicePath(path);

    struct libevdev *dev = NULL;
    int fd;
    int rc = 1;
    fd = open(path.toLatin1(), O_RDONLY|O_NONBLOCK);

    if (fd == -1) {
        return inputDevice;
    }
    rc = libevdev_new_from_fd(fd, &dev);
    if (rc < 0) {
        qWarning() << "Failed to init libevdev ("<< strerror(-rc) << ")";
        return inputDevice;
    }

    inputDevice->setName(QString::fromLatin1(libevdev_get_name(dev)));
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
    return inputDevice;
}

void QInputDeviceInfoPrivate::removeDevice(const QString &path)
{
    for (int i = 0; i < deviceList.size(); ++i) {
        if (deviceList.at(i)->devicePath() == path) {
            delete deviceList.takeAt(i);
            deviceMap.remove(path);
            Q_EMIT deviceRemoved(path);
        }
    }
}

void QInputDeviceInfoPrivate::onUDevChanges()
{
    struct udev_device *dev = udev_monitor_receive_device(udevMonitor);
    if (dev) {
        if (qstrcmp(udev_device_get_subsystem(dev), "input") == 0 ) {
            QString eventPath = QString::fromLatin1(udev_device_get_sysname(dev));

            if (eventPath.contains(QStringLiteral("input")))
                return;

            QString action = QString::fromStdString(udev_device_get_action(dev));

            if (!eventPath.contains(QStringLiteral("/dev/input/")))
                eventPath.prepend(QStringLiteral("/dev/input/"));

            if (action == QStringLiteral("add")) {

                QInputDevice *iDevice = addDevice(eventPath);
                if (!iDevice)
                    return;

                    iDevice->setTypes(getInputTypes(dev));
                    udev_device_unref(dev);

                if (iDevice->switches().count() > 0 && iDevice->buttons().count() == 0)
                    iDevice->setTypes(iDevice->types() | QInputDeviceInfo::Switch);

                if (iDevice->buttons().count() > 0 && iDevice->types() == QInputDeviceInfo::Unknown)
                    iDevice->setTypes(iDevice->types() | QInputDeviceInfo::Button);

                deviceList.append(iDevice);
                deviceMap.insert(eventPath,iDevice);

                Q_EMIT newDevice(eventPath);

            } else if (action == QStringLiteral("remove")) {
                removeDevice(eventPath);
            }
        }
    }
}
