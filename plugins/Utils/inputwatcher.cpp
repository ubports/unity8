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
 *
 */

#include "inputwatcher.h"

#include <QMouseEvent>

InputWatcher::InputWatcher(QObject *parent)
    : QObject(parent)
    , m_mousePressed(false)
    , m_touchPressed(false)
{
}

QObject *InputWatcher::target() const
{
    return m_target;
}

void InputWatcher::setTarget(QObject *value)
{
    if (m_target == value) {
        return;
    }

    if (m_target) {
        m_target->removeEventFilter(this);
    }

    setMousePressed(false);
    setTouchPressed(false);

    m_target = value;
    if (m_target) {
        m_target->installEventFilter(this);
    }

    Q_EMIT targetChanged(value);
}

bool InputWatcher::targetPressed() const
{
    return m_mousePressed || m_touchPressed;
}

bool InputWatcher::eventFilter(QObject* /*watched*/, QEvent *event)
{
    switch (event->type()) {
    case QEvent::TouchBegin:
        setTouchPressed(true);
        break;
    case QEvent::TouchEnd:
        setTouchPressed(false);
        break;
    case QEvent::MouseButtonPress:
        {
            QMouseEvent *mouseEvent = static_cast<QMouseEvent*>(event);
            if (mouseEvent->button() == Qt::LeftButton) {
                setMousePressed(true);
            }
        }
        break;
    case QEvent::MouseButtonRelease:
        {
            QMouseEvent *mouseEvent = static_cast<QMouseEvent*>(event);
            if (mouseEvent->button() == Qt::LeftButton) {
                setMousePressed(false);
            }
        }
        break;
    default:
        // Not interested
        break;
    }

    // We never filter them out. We are just watching.
    return false;
}

void InputWatcher::setMousePressed(bool value)
{
    if (value == m_mousePressed) {
        return;
    }

    bool oldPressed = targetPressed();
    m_mousePressed = value;
    if (targetPressed() != oldPressed) {
        Q_EMIT targetPressedChanged(targetPressed());
    }
}

void InputWatcher::setTouchPressed(bool value)
{
    if (value == m_touchPressed) {
        return;
    }

    bool oldPressed = targetPressed();
    m_touchPressed = value;
    if (targetPressed() != oldPressed) {
        Q_EMIT targetPressedChanged(targetPressed());
    }
}
