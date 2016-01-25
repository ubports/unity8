/*
 * Copyright (C) 2013,2015 Canonical, Ltd.
 *
 * This program is free software; you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation; version 3.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.
 *
 * Authored by: Daniel d'Andrada <daniel.dandrada@canonical.com>
 */


/* Some parts of the code were copied from the XCB platform plugin of the Qt Toolkit,
 * which is under the following license:
 */

/****************************************************************************
**
** Copyright (C) 2015 The Qt Company Ltd.
** Contact: http://www.qt.io/licensing/
**
** This file is part of the .
**
** $QT_BEGIN_LICENSE:LGPL21$
** Commercial License Usage
** Licensees holding valid commercial Qt licenses may use this file in
** accordance with the commercial license agreement provided with the
** Software or, alternatively, in accordance with the terms contained in
** a written agreement between you and The Qt Company. For licensing terms
** and conditions see http://www.qt.io/terms-conditions. For further
** information use the contact form at http://www.qt.io/contact-us.
**
** GNU Lesser General Public License Usage
** Alternatively, this file may be used under the terms of the GNU Lesser
** General Public License version 2.1 or version 3 as published by the Free
** Software Foundation and appearing in the file LICENSE.LGPLv21 and
** LICENSE.LGPLv3 included in the packaging of this file. Please review the
** following information to ensure the GNU Lesser General Public License
** requirements will be met: https://www.gnu.org/licenses/lgpl.html and
** http://www.gnu.org/licenses/old-licenses/lgpl-2.1.html.
**
** As a special exception, The Qt Company gives you certain additional
** rights. These rights are described in The Qt Company LGPL Exception
** version 1.1, included in the file LGPL_EXCEPTION.txt in this package.
**
** $QT_END_LICENSE$
**
****************************************************************************/

#include "MouseTouchAdaptor.h"

#include <qpa/qplatformnativeinterface.h>
#include <qpa/qwindowsysteminterface.h>

#include <QCoreApplication>
#include <QMouseEvent>
#include <QTest>

#include <X11/extensions/XInput2.h>
#include <X11/extensions/XI2proto.h>

using QTest::QTouchEventSequence;

namespace {
MouseTouchAdaptor *g_instance = nullptr;

Qt::MouseButton translateMouseButton(xcb_button_t detail)
{
    switch (detail) {
        case 1: return Qt::LeftButton;
        case 2: return Qt::MidButton;
        case 3: return Qt::RightButton;
        // Button values 4-7 are Wheel events
        default: return Qt::NoButton;
    }
}
} // end of anonymous namespace

MouseTouchAdaptor::MouseTouchAdaptor()
    : QObject(nullptr), m_leftButtonIsPressed(false), m_enabled(true)
{
    QCoreApplication::instance()->installNativeEventFilter(this);

    m_touchDevice = new QTouchDevice;
    m_touchDevice->setType(QTouchDevice::TouchScreen);
    QWindowSystemInterface::registerTouchDevice(m_touchDevice);

    fetchXInput2Info();
}

MouseTouchAdaptor::~MouseTouchAdaptor()
{
    g_instance = nullptr;
}

MouseTouchAdaptor* MouseTouchAdaptor::instance()
{
    if (!g_instance) {
        g_instance = new MouseTouchAdaptor;
    }

    return g_instance;
}

void MouseTouchAdaptor::fetchXInput2Info()
{
    QPlatformNativeInterface *nativeInterface = qGuiApp->platformNativeInterface();
    Display *xDisplay = static_cast<Display*>(nativeInterface->nativeResourceForIntegration("Display"));
    if (xDisplay && XQueryExtension(xDisplay, "XInputExtension", &m_xiOpCode, &m_xiEventBase, &m_xiErrorBase)) {
        int xiMajor = 2;
        m_xi2Minor = 2; // try 2.2 first, needed for TouchBegin/Update/End
        if (XIQueryVersion(xDisplay, &xiMajor, &m_xi2Minor) == BadRequest) {
            m_xi2Minor = 1; // for smooth scrolling 2.1 is enough
            if (XIQueryVersion(xDisplay, &xiMajor, &m_xi2Minor) == BadRequest) {
                m_xi2Minor = 0; // for tablet support 2.0 is enough
                m_xi2Enabled = XIQueryVersion(xDisplay, &xiMajor, &m_xi2Minor) != BadRequest;
            } else
                m_xi2Enabled = true;
        } else {
            m_xi2Enabled = true;
        }
    }
}

// Starting from the xcb version 1.9.3 struct xcb_ge_event_t has changed:
// - "pad0" became "extension"
// - "pad1" and "pad" became "pad0"
// New and old version of this struct share the following fields:
// NOTE: API might change again in the next release of xcb in which case this comment will
// need to be updated to reflect the reality.
typedef struct qt_xcb_ge_event_t {
    uint8_t  response_type;
    uint8_t  extension;
    uint16_t sequence;
    uint32_t length;
    uint16_t event_type;
} qt_xcb_ge_event_t;

bool xi2PrepareXIGenericDeviceEvent(xcb_ge_event_t *ev, int opCode)
{
    qt_xcb_ge_event_t *event = (qt_xcb_ge_event_t *)ev;
    // xGenericEvent has "extension" on the second byte, the same is true for xcb_ge_event_t starting from
    // the xcb version 1.9.3, prior to that it was called "pad0".
    if (event->extension == opCode) {
        // xcb event structs contain stuff that wasn't on the wire, the full_sequence field
        // adds an extra 4 bytes and generic events cookie data is on the wire right after the standard 32 bytes.
        // Move this data back to have the same layout in memory as it was on the wire
        // and allow casting, overwriting the full_sequence field.
        memmove((char*) event + 32, (char*) event + 36, event->length * 4);
        return true;
    }
    return false;
}

static inline qreal fixed1616ToReal(FP1616 val)
{
    return qreal(val) / 0x10000;
}

bool MouseTouchAdaptor::xi2HandleEvent(xcb_ge_event_t *event)
{
    if (!xi2PrepareXIGenericDeviceEvent(event, m_xiOpCode)) {
        return false;
    }

    xXIGenericDeviceEvent *xiEvent = reinterpret_cast<xXIGenericDeviceEvent *>(event);
    xXIDeviceEvent *xiDeviceEvent = 0;

    switch (xiEvent->evtype) {
    case XI_ButtonPress:
    case XI_ButtonRelease:
    case XI_Motion:
        xiDeviceEvent = reinterpret_cast<xXIDeviceEvent *>(event);
        break;
    default:
        break;
    }

    if (!xiDeviceEvent) {
        return false;
    }

    switch (xiDeviceEvent->evtype) {
    case XI_ButtonPress:
        return handleButtonPress(
                static_cast<WId>(xiDeviceEvent->event),
                xiDeviceEvent->detail,
                fixed1616ToReal(xiDeviceEvent->event_x),
                fixed1616ToReal(xiDeviceEvent->event_y));
    case XI_ButtonRelease:
        return handleButtonRelease(
                static_cast<WId>(xiDeviceEvent->event),
                xiDeviceEvent->detail,
                fixed1616ToReal(xiDeviceEvent->event_x),
                fixed1616ToReal(xiDeviceEvent->event_y));
    case XI_Motion:
        return handleMotionNotify(
                static_cast<WId>(xiDeviceEvent->event),
                fixed1616ToReal(xiDeviceEvent->event_x),
                fixed1616ToReal(xiDeviceEvent->event_y));
        return true;
    default:
        return false;
    }
}


bool MouseTouchAdaptor::nativeEventFilter(const QByteArray & eventType,
                                          void * message, long * /*result*/)
{
    static int eventCount = 0;
    eventCount++;
    if (!m_enabled) {
        return false;
    }

    if (eventType != "xcb_generic_event_t") {
        // wrong backend.
        qWarning("MouseTouchAdaptor: XCB backend not in use. Adaptor inoperative!");
        return false;
    }

    xcb_generic_event_t *xcbEvent = static_cast<xcb_generic_event_t *>(message);

    switch (xcbEvent->response_type & ~0x80) {
        case XCB_BUTTON_PRESS: {
            auto pressEvent = reinterpret_cast<xcb_button_press_event_t *>(xcbEvent);
            return handleButtonPress(static_cast<WId>(pressEvent->event), pressEvent->detail,
                    pressEvent->event_x, pressEvent->event_y);
        }
        case XCB_BUTTON_RELEASE: {
            auto releaseEvent = reinterpret_cast<xcb_button_release_event_t *>(xcbEvent);
            return handleButtonRelease(static_cast<WId>(releaseEvent->event), releaseEvent->detail,
                    releaseEvent->event_x, releaseEvent->event_y);
        }
        case XCB_MOTION_NOTIFY: {
            auto motionEvent = reinterpret_cast<xcb_motion_notify_event_t *>(xcbEvent);
            return handleMotionNotify(static_cast<WId>(motionEvent->event), motionEvent->event_x, motionEvent->event_y);
        }
        case XCB_GE_GENERIC:
            if (m_xi2Enabled) {
                return xi2HandleEvent(reinterpret_cast<xcb_ge_event_t *>(xcbEvent));
            } else {
                return false;
            }
        default:
            return false;
    };
}

bool MouseTouchAdaptor::handleButtonPress(WId windowId, uint32_t detail, int x, int y)
{
    Qt::MouseButton button = translateMouseButton(detail);

    // Just eat the event if it wasn't a left mouse press
    if (button != Qt::LeftButton)
        return true;

    QWindow *targetWindow = findQWindowWithXWindowID(windowId);

    QPoint windowPos(x / targetWindow->devicePixelRatio(), y / targetWindow->devicePixelRatio());

    QTouchEventSequence touchEvent = QTest::touchEvent(targetWindow, m_touchDevice,
                                                       false /* autoCommit */);
    touchEvent.press(0 /* touchId */, windowPos);
    touchEvent.commit(false /* processEvents */);

    m_leftButtonIsPressed = true;
    return true;
}

bool MouseTouchAdaptor::handleButtonRelease(WId windowId, uint32_t detail, int x, int y)
{
    Qt::MouseButton button = translateMouseButton(detail);

    // Just eat the event if it wasn't a left mouse release
    if (button != Qt::LeftButton)
        return true;

    QWindow *targetWindow = findQWindowWithXWindowID(windowId);

    QPoint windowPos(x / targetWindow->devicePixelRatio(), y / targetWindow->devicePixelRatio());

    QTouchEventSequence touchEvent = QTest::touchEvent(targetWindow, m_touchDevice,
                                                       false /* autoCommit */);
    touchEvent.release(0 /* touchId */, windowPos);
    touchEvent.commit(false /* processEvents */);

    m_leftButtonIsPressed = false;
    return true;
}

bool MouseTouchAdaptor::handleMotionNotify(WId windowId, int x, int y)
{
    if (!m_leftButtonIsPressed) {
        return true;
    }

    QWindow *targetWindow = findQWindowWithXWindowID(windowId);

    QPoint windowPos(x / targetWindow->devicePixelRatio(), y / targetWindow->devicePixelRatio());

    QTouchEventSequence touchEvent = QTest::touchEvent(targetWindow, m_touchDevice,
                                                       false /* autoCommit */);
    touchEvent.move(0 /* touchId */, windowPos);
    touchEvent.commit(false /* processEvents */);

    return true;
}

QWindow *MouseTouchAdaptor::findQWindowWithXWindowID(WId windowId)
{
    QWindowList windowList = QGuiApplication::topLevelWindows();
    QWindow *foundWindow = nullptr;

    int i = 0;
    while (!foundWindow && i < windowList.count()) {
        QWindow *window = windowList[i];
        if (window->winId() == windowId) {
            foundWindow = window;
        } else {
            ++i;
        }
    }

    Q_ASSERT(foundWindow);
    return foundWindow;
}

bool MouseTouchAdaptor::enabled() const
{
    return m_enabled;
}

void MouseTouchAdaptor::setEnabled(bool value)
{
    if (value != m_enabled) {
        m_enabled = value;
        Q_EMIT enabledChanged(value);
    }
}
