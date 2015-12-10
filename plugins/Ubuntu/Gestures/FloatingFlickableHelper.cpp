/*
 * Copyright (C) 2015 Canonical, Ltd.
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
 */

#include "FloatingFlickableHelper.h"

#include <QCoreApplication>
#include <QMouseEvent>
#include <QQuickItem>

FloatingFlickableHelper::FloatingFlickableHelper(QObject *parent)
    : QObject(parent)
    , m_mousePressed(false)
{
}

void FloatingFlickableHelper::onDragAreaTouchPosChanged(QQuickItem *flickable, const QPointF touchPosition)
{
    if (m_mousePressed) {
        QMouseEvent mouseEvent(QEvent::MouseMove,
                QPointF(touchPosition.x(), touchPosition.y()),
                Qt::NoButton, Qt::LeftButton, Qt::NoModifier);

        QCoreApplication::sendEvent(flickable, &mouseEvent);

    }
}

void FloatingFlickableHelper::onDragAreaDraggingChanged(QQuickItem *flickable, bool dragging, const QPointF touchPosition)
{
    if (dragging && !m_mousePressed) {
        QMouseEvent mouseEvent(QEvent::MouseButtonPress,
                QPointF(touchPosition.x(), touchPosition.y()),
                Qt::LeftButton, Qt::LeftButton, Qt::NoModifier);

        QCoreApplication::sendEvent(flickable, &mouseEvent);
        m_mousePressed = true;

    } else if (!dragging && m_mousePressed) {
        QMouseEvent mouseEvent(QEvent::MouseButtonRelease,
                QPointF(touchPosition.x(), touchPosition.y()),
                Qt::LeftButton, Qt::LeftButton, Qt::NoModifier);

        QCoreApplication::sendEvent(flickable, &mouseEvent);
        m_mousePressed = false;
    }
}
