/*
 * Copyright (C) 2013 Canonical, Ltd.
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

#include "MouseTouchAdaptor.h"

#include <qpa/qwindowsysteminterface.h>

#include <QtGui/QMouseEvent>
#include <QtTest/QTest>

using QTest::QTouchEventSequence;

namespace {
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
    : m_leftButtonIsPressed(false)
{
    m_touchDevice = new QTouchDevice;
    m_touchDevice->setType(QTouchDevice::TouchScreen);
    QWindowSystemInterface::registerTouchDevice(m_touchDevice);
}

bool MouseTouchAdaptor::nativeEventFilter(const QByteArray & eventType,
                                          void * message, long * /*result*/)
{
    if (eventType != "xcb_generic_event_t") {
        // wrong backend.
        qWarning("MouseTouchAdaptor: XCB backend not in use. Adaptor inoperative!");
        return false;
    }

    xcb_generic_event_t *xcbEvent = static_cast<xcb_generic_event_t *>(message);

    switch (xcbEvent->response_type & ~0x80) {
        case XCB_BUTTON_PRESS:
            return handleButtonPress(reinterpret_cast<xcb_button_press_event_t *>(xcbEvent));
            break;
        case XCB_BUTTON_RELEASE:
            return handleButtonRelease(reinterpret_cast<xcb_button_release_event_t *>(xcbEvent));
            break;
        case XCB_MOTION_NOTIFY:
            return handleMotionNotify(reinterpret_cast<xcb_motion_notify_event_t *>(xcbEvent));
            break;
        default:
            return false;
            break;
    };
}

bool MouseTouchAdaptor::handleButtonPress(xcb_button_press_event_t *pressEvent)
{
    Qt::MouseButton button = translateMouseButton(pressEvent->detail);

    // Just eat the event if it wasn't a left mouse press
    if (button != Qt::LeftButton)
        return true;

    QPoint windowPos(pressEvent->event_x, pressEvent->event_y);

    QWindow *targetWindow = findQWindowWithXWindowID(static_cast<WId>(pressEvent->event));

    QTouchEventSequence touchEvent = QTest::touchEvent(targetWindow, m_touchDevice,
                                                       false /* autoCommit */);
    touchEvent.press(0 /* touchId */, windowPos);
    touchEvent.commit(false /* processEvents */);

    m_leftButtonIsPressed = true;
    return true;
}

bool MouseTouchAdaptor::handleButtonRelease(xcb_button_release_event_t *releaseEvent)
{
    Qt::MouseButton button = translateMouseButton(releaseEvent->detail);

    // Just eat the event if it wasn't a left mouse release
    if (button != Qt::LeftButton)
        return true;

    QPoint windowPos(releaseEvent->event_x, releaseEvent->event_y);

    QWindow *targetWindow = findQWindowWithXWindowID(static_cast<WId>(releaseEvent->event));

    QTouchEventSequence touchEvent = QTest::touchEvent(targetWindow, m_touchDevice,
                                                       false /* autoCommit */);
    touchEvent.release(0 /* touchId */, windowPos);
    touchEvent.commit(false /* processEvents */);

    m_leftButtonIsPressed = false;
    return true;
}

bool MouseTouchAdaptor::handleMotionNotify(xcb_motion_notify_event_t *event)
{
    if (!m_leftButtonIsPressed) {
        return true;
    }

    QPoint windowPos(event->event_x, event->event_y);

    QWindow *targetWindow = findQWindowWithXWindowID(static_cast<WId>(event->event));

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
