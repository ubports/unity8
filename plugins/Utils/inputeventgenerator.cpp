/*
 * Copyright (C) 2016 Canonical, Ltd.
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

#include "inputeventgenerator.h"

#include <QQuickWindow>
#include <QDebug>
#include <QDateTime>

InputEventGenerator::InputEventGenerator(QQuickItem *parent)
    : QQuickItem(parent)
{
}

void InputEventGenerator::generateKeyEvent(Qt::Key key, bool pressed, Qt::KeyboardModifiers modifiers, quint64 timestamp, quint32 nativeScanCode, const QString &text)
{
    QEvent::Type type = pressed ? QEvent::KeyPress : QEvent::KeyRelease;
    QKeyEvent ev(type, key, modifiers, nativeScanCode, 0, 0, text);
    ev.setTimestamp(timestamp);
    QCoreApplication::sendEvent(window(), &ev);
}
