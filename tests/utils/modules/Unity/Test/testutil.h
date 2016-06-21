/*
 * Copyright (C) 2012, 2013, 2014 Canonical, Ltd.
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


#ifndef TESTUTIL_H
#define TESTUTIL_H

#include "TouchEventSequenceWrapper.h"
#include <QtQuick/QQuickItem>

class QTouchDevice;

class TestUtil : public QObject
{
    Q_OBJECT
    Q_DISABLE_COPY(TestUtil)

public:
    TestUtil(QObject *parent = 0);
    ~TestUtil();

    Q_INVOKABLE bool isInstanceOf(QObject*, QString);
    Q_INVOKABLE void waitForBehaviors(QObject *obj);
    Q_INVOKABLE TouchEventSequenceWrapper *touchEvent(QQuickItem *item);

private:
    void ensureTargetWindow();
    void ensureTouchDevice();

    QWindow *m_targetWindow;
    QTouchDevice *m_touchDevice;
    bool m_putFakeTimerFactoryInTouchRegistry;
};

QML_DECLARE_TYPE(TestUtil)

#endif // TESTUTIL_H
