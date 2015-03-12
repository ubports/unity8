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

#ifndef MOUSE_TOUCH_ADAPTOR_H
#define MOUSE_TOUCH_ADAPTOR_H

#include <QtCore/QAbstractNativeEventFilter>
#include <QWindow>
#include <xcb/xcb.h>

class QMouseEvent;
class QTouchDevice;

// Transforms QMouseEvents into single-finger QTouchEvents.
class MouseTouchAdaptor : public QObject, public QAbstractNativeEventFilter {
    Q_OBJECT
public:
    virtual ~MouseTouchAdaptor();

    static MouseTouchAdaptor* instance();

    // Filters mouse events and posts the equivalent QTouchEvents.
    bool nativeEventFilter(const QByteArray & eventType, void *message, long *result) override;

    Q_PROPERTY(bool enabled READ enabled WRITE setEnabled NOTIFY enabledChanged)

    bool enabled() const;
    void setEnabled(bool value);

Q_SIGNALS:
    void enabledChanged(bool value);

private:
    MouseTouchAdaptor();

    bool handleButtonPress(xcb_button_press_event_t *pressEvent);
    bool handleButtonRelease(xcb_button_release_event_t *releaseEvent);
    bool handleMotionNotify(xcb_motion_notify_event_t *event);
    QWindow *findQWindowWithXWindowID(WId windowId);

    QTouchDevice *m_touchDevice;
    bool m_leftButtonIsPressed;

    bool m_enabled;
};

#endif // MOUSE_TOUCH_ADAPTOR_H
