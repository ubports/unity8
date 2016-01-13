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
  * \brief This class allows injecting Key events into the scene.
  */
class InputEventGenerator : public QQuickItem
{
    Q_OBJECT
public:
    InputEventGenerator(QQuickItem *parent = 0);

    /**
      * Generate and post and event to the scene. Note that the event will not be dispatched directly to the "receiver" but
      * instead to the window where the item is located. With that, the whole scene will receive the keypress and it will
      * be dispatched through the regular event/focus queue.
      */
    Q_INVOKABLE void generateEvent(QQuickItem *receiver, Qt::Key key, bool pressed, Qt::KeyboardModifiers modifiers = Qt::NoModifier, quint64 timestamp = QDateTime::currentMSecsSinceEpoch(), quint32 nativeScanCode = 0, const QString &text = QString());
};

#endif // INPUTEVENTGENERATOR_H
