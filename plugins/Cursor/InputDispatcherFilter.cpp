/*
 * Copyright (C) 2016 Canonical, Ltd.
 *
 * This program is free software: you can redistribute it and/or modify it under
 * the terms of the GNU Lesser General Public License version 3, as published by
 * the Free Software Foundation.
 *
 * This program is distributed in the hope that it will be useful, but WITHOUT
 * ANY WARRANTY; without even the implied warranties of MERCHANTABILITY,
 * SATISFACTORY QUALITY, or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
 * Lesser General Public License for more details.
 *
 * You should have received a copy of the GNU Lesser General Public License
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.
 */

#include "InputDispatcherFilter.h"
#include "MousePointer.h"

#include <QEvent>
#include <QGuiApplication>
#include <QQuickWindow>
#include <QScreen>
#include <qpa/qplatformnativeinterface.h>
#include <qpa/qplatformscreen.h>

#include <QTimer>

InputDispatcherFilter *InputDispatcherFilter::instance()
{
    static InputDispatcherFilter filter;
    return &filter;
}

InputDispatcherFilter::InputDispatcherFilter(QObject *parent)
    : QObject(parent)
{
    QPlatformNativeInterface *ni = QGuiApplication::platformNativeInterface();
    m_inputDispatcher = static_cast<QObject*>(ni->nativeResourceForIntegration("InputDispatcher"));
    if (m_inputDispatcher) {
        m_inputDispatcher->installEventFilter(this);
    }

    QTimer* timer(new QTimer());
    connect(timer, &QTimer::timeout, this, []() {
        static int i = 0;
        auto allWindows = QGuiApplication::topLevelWindows();
        if (allWindows.count()) {
            QWindow* window = QGuiApplication::topLevelWindows()[i++ % QGuiApplication::topLevelWindows().count()];
            if (window) {
                window->requestActivate();
            }
        }
    });
    timer->setInterval(5000);
    timer->start();
}

void InputDispatcherFilter::registerPointer(MousePointer *pointer)
{
    // allow first registered pointer to be visible.
    m_pointers.insert(pointer);
}

void InputDispatcherFilter::unregisterPointer(MousePointer *pointer)
{
    m_pointers.remove(pointer);
}

bool InputDispatcherFilter::eventFilter(QObject *o, QEvent *e)
{
    if (o != m_inputDispatcher) return false;

    switch (e->type()) {
        case QEvent::MouseMove:
        case QEvent::MouseButtonPress:
        case QEvent::MouseButtonRelease:
        {
            // if we don't have any pointers, filter all mouse events.
            auto pointer = currentPointer();
            if (!pointer) return true;

            QMouseEvent* me = static_cast<QMouseEvent*>(e);

            // Local position gives relative change of mouse pointer.
            QPointF movement = me->localPos();

            // Adjust the position
            QPointF oldPos = pointer->window()->geometry().topLeft() + pointer->position();
            QPointF newPos = adjustedPositionForMovement(oldPos, movement);

            QScreen* currentScreen = screenAt(newPos);
            if (currentScreen) {
                QRect screenRect = currentScreen->geometry();
                qreal unadjustedX = (oldPos + movement).x();
                if (unadjustedX < screenRect.left()) {
                    Q_EMIT pushedLeftBoundary(currentScreen, qAbs(unadjustedX - screenRect.left()), me->buttons());
                } else if (unadjustedX > screenRect.right()) {
                    Q_EMIT pushedRightBoundary(currentScreen, qAbs(unadjustedX - screenRect.right()), me->buttons());
                }
            }

            // Send the event
            QMouseEvent eCopy(me->type(), me->localPos(), newPos, me->button(), me->buttons(), me->modifiers());
            eCopy.setTimestamp(me->timestamp());
            o->event(&eCopy);
            return true;
        }
        default:
            break;
    }
    return false;
}

QPointF InputDispatcherFilter::adjustedPositionForMovement(const QPointF &pt, const QPointF &movement) const
{
    QPointF adjusted = pt + movement;

    auto screen = screenAt(adjusted); // first check if our move was to a screen with an enabled pointer.
    if (screen) {
        return adjusted;
    } else if ((screen = screenAt(pt))) { // then check if our old position was valid
        QRectF screenBounds = screen->geometry();
        // bound the new position to the old screen geometry
        adjusted.rx() = qMax(screenBounds.left(), qMin(adjusted.x(), screenBounds.right()-1));
        adjusted.ry() = qMax(screenBounds.top(), qMin(adjusted.y(), screenBounds.bottom()-1));
    } else {
        auto screens = QGuiApplication::screens();

        // center of first screen with a pointer.
        Q_FOREACH(QScreen* screen, screens) {
            Q_FOREACH(MousePointer* pointer, m_pointers) {
                if (pointer->isEnabled() && pointer->screen() == screen) {
                    return screen->geometry().center();
                }
            }
        }
    }
    return adjusted;
}

QScreen *InputDispatcherFilter::screenAt(const QPointF &pt) const
{
    Q_FOREACH(MousePointer* pointer, m_pointers) {
        if (!pointer->isEnabled()) continue;

        QScreen* screen = pointer->screen();
        if (screen && screen->geometry().contains(pt.toPoint()))
            return screen;
    }
    return nullptr;
}

MousePointer *InputDispatcherFilter::currentPointer() const
{
    Q_FOREACH(MousePointer* pointer, m_pointers) {
        if (!pointer->isEnabled()) continue;
        return pointer;
    }
    return nullptr;
}
