/*
 * Copyright (C) 2013 Canonical, Ltd.
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

#ifndef GESTURETEST_H
#endif // GESTURETEST_H

#include <QObject>

class QQuickView;
class QTouchDevice;

/*
    The common stuff among tests come here
 */
class GestureTest : public QObject
{
    Q_OBJECT
public:
    GestureTest() : QObject(), m_device(nullptr), m_view(nullptr) {}

protected Q_SLOTS:
    void initTestCase(); // will be called before the first test function is executed
    virtual void init(); // called right before each and every test function is executed
    virtual void cleanup(); // called right after each and every test function is executed

protected:
    QTouchDevice *m_device;
    QQuickView *m_view;
};

#define GESTURETEST_H
