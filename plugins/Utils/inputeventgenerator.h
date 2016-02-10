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

#ifndef INPUTEVENTGENERATOR_H
#define INPUTEVENTGENERATOR_H

#include <QQuickItem>
#include <QPointer>
#include <QDateTime>

/**
  * \brief This class allows injecting Key events into the scene it lives in.
  */
class InputEventGenerator : public QQuickItem
{
    Q_OBJECT
public:
    InputEventGenerator(QQuickItem *parent = 0);

    /**
      * Generate and post and event to the scene. The key event will be sent to the scene the Generator
      * lives in and it will be dispatched through the regular event/focus queue.
      */
    Q_INVOKABLE void generateKeyEvent(Qt::Key key, bool pressed, Qt::KeyboardModifiers modifiers = Qt::NoModifier, quint64 timestamp = QDateTime::currentMSecsSinceEpoch(), quint32 nativeScanCode = 0, const QString &text = QString());
};

#endif // INPUTEVENTGENERATOR_H
