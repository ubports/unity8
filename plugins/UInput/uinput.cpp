/*
 * Copyright (C) 2015 Canonical Ltd.
 *
 * This program is free software: you can redistribute it and/or modify it
 * under the terms of the GNU General Public License version 3, as published
 * by the Free Software Foundation.
 *
 * This program is distributed in the hope that it will be useful, but
 * WITHOUT ANY WARRANTY; without even the implied warranties of
 * MERCHANTABILITY, SATISFACTORY QUALITY, or FITNESS FOR A PARTICULAR
 * PURPOSE.  See the GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License along
 * with this program.  If not, see <http://www.gnu.org/licenses/>.
 */

#include "uinput.h"

#include <QFile>
#include <QDebug>
#include <QDateTime>

#include <unistd.h>
#include <time.h>

UInput::UInput(QObject *parent) :
    QObject(parent)
{
    m_devName = QByteArrayLiteral("unity8-simulated-mouse");
    m_uinput.setFileName(QStringLiteral("/dev/uinput"));

    memset(&m_uinput_mouse_dev, 0, sizeof(m_uinput_mouse_dev));
    m_uinput_mouse_dev.id.bustype = BUS_USB;
    m_uinput_mouse_dev.id.version = 1;
    strncpy(m_uinput_mouse_dev.name, m_devName.constData(), m_devName.length());
}

UInput::~UInput()
{
    if (m_mouseCreated) {
        removeMouse();
    }
}

void UInput::createMouse()
{
    if (m_mouseCreated) {
        qDebug() << "Already have a virtual device. Not creating another one.";
        return;
    }

    if (!m_uinput.isOpen() && !m_uinput.open(QFile::WriteOnly)) {
        return;
    }

    ioctl(m_uinput.handle(), UI_SET_EVBIT, EV_REL);
    ioctl(m_uinput.handle(), UI_SET_RELBIT, REL_X);
    ioctl(m_uinput.handle(), UI_SET_RELBIT, REL_Y);
    ioctl(m_uinput.handle(), UI_SET_RELBIT, REL_HWHEEL);
    ioctl(m_uinput.handle(), UI_SET_RELBIT, REL_WHEEL);

    ioctl(m_uinput.handle(), UI_SET_EVBIT, EV_KEY);
    ioctl(m_uinput.handle(), UI_SET_KEYBIT, BTN_MOUSE);
    ioctl(m_uinput.handle(), UI_SET_KEYBIT, BTN_LEFT);
    ioctl(m_uinput.handle(), UI_SET_KEYBIT, BTN_MIDDLE);
    ioctl(m_uinput.handle(), UI_SET_KEYBIT, BTN_RIGHT);
    ioctl(m_uinput.handle(), UI_SET_KEYBIT, BTN_FORWARD);
    ioctl(m_uinput.handle(), UI_SET_KEYBIT, BTN_BACK);

    ioctl(m_uinput.handle(), UI_SET_EVBIT, EV_SYN);

    int len = write(m_uinput.handle(), &m_uinput_mouse_dev, sizeof(m_uinput_mouse_dev));
    if (len <= 0) {
        qWarning() << "Failed to write to uinput. Cannot create virtual uinput mouse.";
        return;
    }

    int err = ioctl(m_uinput.handle(), UI_DEV_CREATE);
    if (err != 0) {
        qWarning() << "Cannot create virtual uinput device. Create ioctl failed:" << err;
        return;
    }
    m_mouseCreated = true;
    qDebug() << "Virtual uinput mouse device created.";
}

void UInput::removeMouse()
{
    if (!m_mouseCreated) {
        return;
    }

    if (!m_uinput.isOpen() && !m_uinput.open(QFile::WriteOnly)) {
        qWarning() << "cannot open uinput... ";
        return;
    }

    int err = ioctl(m_uinput.handle(), UI_DEV_DESTROY);
    if (err != 0) {
        qWarning() << "Failed to destroy virtual uinput device. Destroy ioctl failed:" << err;
    } else {
        qDebug() << "Virtual uinput mouse device removed.";
    }
    m_uinput.close();
    m_mouseCreated = false;
}

void UInput::moveMouse(int dx, int dy)
{
    struct input_event event;
    memset(&event, 0, sizeof(event));
    clock_gettime(CLOCK_MONOTONIC, (timespec*)&event.time);
    event.type = EV_REL;
    event.code = REL_X;
    event.value = dx;
    write(m_uinput.handle(), &event, sizeof(event));

    event.code = REL_Y;
    event.value = dy;
    write(m_uinput.handle(), &event, sizeof(event));

    event.type = EV_SYN;
    event.code = SYN_REPORT;
    event.value = 0;
    write(m_uinput.handle(), &event, sizeof(event));
}

void UInput::pressMouse(Button button)
{
    injectMouse(button, 1);
}

void UInput::releaseMouse(Button button)
{
    injectMouse(button, 0);
}

void UInput::scrollMouse(int dh, int dv)
{
    struct input_event event;
    memset(&event, 0, sizeof(event));
    clock_gettime(CLOCK_MONOTONIC, (timespec*)&event.time);
    event.type = EV_REL;
    event.code = REL_HWHEEL;
    event.value = dh;
    write(m_uinput.handle(), &event, sizeof(event));

    event.code = REL_WHEEL;
    event.value = dv;
    write(m_uinput.handle(), &event, sizeof(event));

    event.type = EV_SYN;
    event.code = SYN_REPORT;
    event.value = 0;
    write(m_uinput.handle(), &event, sizeof(event));
}

void UInput::injectMouse(Button button, int down)
{
    struct input_event event;
    memset(&event, 0, sizeof(event));
    clock_gettime(CLOCK_MONOTONIC, (timespec*)&event.time);
    event.type = EV_KEY;
    switch (button) {
    case ButtonLeft:
        event.code = BTN_LEFT;
        break;
    case ButtonRight:
        event.code = BTN_RIGHT;
        break;
    case ButtonMiddle:
        event.code = BTN_MIDDLE;
        break;
    }
    event.value = down;
    write(m_uinput.handle(), &event, sizeof(event));

    event.type = EV_SYN;
    event.code = SYN_REPORT;
    event.value = 0;
    write(m_uinput.handle(), &event, sizeof(event));
}
