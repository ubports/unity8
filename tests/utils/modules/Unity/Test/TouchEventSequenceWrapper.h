/*
 * Copyright 2013-2016 Canonical Ltd.
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

#ifndef TOUCH_EVENT_SEQUENCE_WRAPPER_H
#define TOUCH_EVENT_SEQUENCE_WRAPPER_H

#include <QtCore/QObject>
#include <QtTest/QTest>
#include <QtQml/qqml.h>

#include <QPointer>

class QQuickItem;

class TouchEventSequenceWrapper : public QObject
{
    Q_OBJECT
public:
    TouchEventSequenceWrapper(QTest::QTouchEventSequence eventSequence, QQuickItem *item);

    Q_INVOKABLE void commit(bool processEvents = true);
    Q_INVOKABLE void move(int touchId, int x, int y);
    Q_INVOKABLE void press(int touchId, int x, int y);
    Q_INVOKABLE void release(int touchId, int x, int y);
    Q_INVOKABLE void stationary(int touchId);

private:
    QTest::QTouchEventSequence m_eventSequence;
    QPointer<QQuickItem> m_item;
};

QML_DECLARE_TYPE(TouchEventSequenceWrapper)

#endif // TOUCH_EVENT_SEQUENCE_WRAPPER_H
