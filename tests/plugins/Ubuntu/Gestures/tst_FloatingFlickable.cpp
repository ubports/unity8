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

#include <QtTest>
#include <QQuickView>

#include "FloatingFlickable.h"

#include "GestureTest.h"

using namespace UbuntuGestures;

class tst_FloatingFlickable: public GestureTest
{
    Q_OBJECT
public:
    tst_FloatingFlickable();
private Q_SLOTS:
    void init(); // called right before each and every test function is executed

    void foo();

};

tst_FloatingFlickable::tst_FloatingFlickable()
    : GestureTest(QStringLiteral("tst_FloatingFlickable.qml"))
{
}

void tst_FloatingFlickable::init()
{
    GestureTest::init();

    // We shouldn't need the three lines below, but a compiz/unity7
    // regression means we don't pass the test without them because
    // the window doesn't have the proper size. Can be removed in the
    // future if the regression is fixed and tests pass again
    m_view->resize(m_view->rootObject()->width(), m_view->rootObject()->height());
    QTRY_COMPARE(m_view->width(), (int)m_view->rootObject()->width());
    QTRY_COMPARE(m_view->height(), (int)m_view->rootObject()->height());
}

void tst_FloatingFlickable::foo()
{
}


QTEST_MAIN(tst_FloatingFlickable)

#include "tst_FloatingFlickable.moc"
