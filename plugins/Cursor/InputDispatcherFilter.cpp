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
#include <QtMath>
#include <qpa/qplatformnativeinterface.h>
#include <qpa/qplatformscreen.h>

InputDispatcherFilter *InputDispatcherFilter::instance()
{
    static InputDispatcherFilter filter;
    return &filter;
}

InputDispatcherFilter::InputDispatcherFilter(QObject *parent)
    : QObject(parent)
    , m_pushing(false)
{
    QPlatformNativeInterface *ni = QGuiApplication::platformNativeInterface();
    m_inputDispatcher = static_cast<QObject*>(ni->nativeResourceForIntegration("InputDispatcher"));
    if (m_inputDispatcher) {
        m_inputDispatcher->installEventFilter(this);
    }
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
                qreal newX = (oldPos + movement).x();
                qreal newY = (oldPos + movement).y();

                if (newX <= screenRect.left() && newY < screenRect.top() + pointer->topBoundaryOffset()) { // top left corner
                    const auto distance = qSqrt(qPow(newX, 2) + qPow(newY- screenRect.top() - pointer->topBoundaryOffset(), 2));
                    Q_EMIT pushedTopLeftCorner(currentScreen, qAbs(distance), me->buttons());
                    m_pushing = true;
                } else if (newX >= screenRect.right()-1 && newY < screenRect.top() + pointer->topBoundaryOffset()) { // top right corner
                    const auto distance = qSqrt(qPow(newX-screenRect.right(), 2) + qPow(newY - screenRect.top() - pointer->topBoundaryOffset(), 2));
                    Q_EMIT pushedTopRightCorner(currentScreen, qAbs(distance), me->buttons());
                    m_pushing = true;
                } else if (newX < 0 && newY >= screenRect.bottom()-1) { // bottom left corner
                    const auto distance = qSqrt(qPow(newX, 2) + qPow(newY-screenRect.bottom(), 2));
                    Q_EMIT pushedBottomLeftCorner(currentScreen, qAbs(distance), me->buttons());
                    m_pushing = true;
                } else if (newX >= screenRect.right()-1 && newY >= screenRect.bottom()-1) { // bottom right corner
                    const auto distance = qSqrt(qPow(newX-screenRect.right(), 2) + qPow(newY-screenRect.bottom(), 2));
                    Q_EMIT pushedBottomRightCorner(currentScreen, qAbs(distance), me->buttons());
                    m_pushing = true;
                } else if (newX <  screenRect.left()) { // left edge
                    Q_EMIT pushedLeftBoundary(currentScreen, qAbs(newX), me->buttons());
                    m_pushing = true;
                } else if (newX >=  screenRect.right()) { // right edge
                    Q_EMIT pushedRightBoundary(currentScreen, newX - (screenRect.right() - 1), me->buttons());
                    m_pushing = true;
                } else if (newY < screenRect.top() + pointer->topBoundaryOffset()) { // top edge
                    Q_EMIT pushedTopBoundary(currentScreen, qAbs(newY - screenRect.top() - pointer->topBoundaryOffset()), me->buttons());
                    m_pushing = true;
                } else if (Q_LIKELY(newX > 0 && newX < screenRect.right()-1 && newY > 0 && newY < screenRect.bottom()-1)) { // normal pos, not pushing
                    if (m_pushing) {
                        Q_EMIT pushStopped(currentScreen);
                        m_pushing = false;
                    }
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
