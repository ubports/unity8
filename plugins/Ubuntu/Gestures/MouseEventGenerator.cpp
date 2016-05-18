/*
 * Copyright (C) 2015-2016 Canonical, Ltd.
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

#include "MouseEventGenerator.h"

#include <QCoreApplication>
#include <QMouseEvent>
#include <QQuickItem>

MouseEventGenerator::MouseEventGenerator(QObject *parent)
    : QObject(parent)
{
}

void MouseEventGenerator::move(const QPointF position)
{
    if (!m_mousePressed || !m_targetItem) {
        return;
    }

    QMouseEvent mouseEvent(QEvent::MouseMove,
            QPointF(position.x(), position.y()), Qt::NoButton, Qt::LeftButton, Qt::NoModifier);

    QCoreApplication::sendEvent(m_targetItem, &mouseEvent);
}

void MouseEventGenerator::press(const QPointF position)
{
    if (m_mousePressed || !m_targetItem) {
        return;
    }

    QMouseEvent mouseEvent(QEvent::MouseButtonPress,
            QPointF(position.x(), position.y()), Qt::LeftButton, Qt::LeftButton, Qt::NoModifier);

    QCoreApplication::sendEvent(m_targetItem, &mouseEvent);
    m_mousePressed = true;
}

void MouseEventGenerator::release(const QPointF position)
{
    if (!m_mousePressed || !m_targetItem) {
        return;
    }

    QMouseEvent mouseEvent(QEvent::MouseButtonRelease,
            QPointF(position.x(), position.y()), Qt::LeftButton, Qt::LeftButton, Qt::NoModifier);

    QCoreApplication::sendEvent(m_targetItem, &mouseEvent);
    m_mousePressed = false;
}
