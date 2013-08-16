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

// local
#include "signalslisttest.h"
#include "signalslist.h"

// Qt
#include <QTest>

class TestSource
{
    public:
        TestSource(): m_count(0) {}
        void update()
        {
            countChanged(++m_count);
        }

        sigc::signal<void, int> countChanged;
        int m_count;
};

void SignalsListTest::testSignalsList()
{
    TestSource src;
    SignalsList signals;
    int counter = -1;

    signals << src.countChanged.connect([&counter](int val) {
        counter = val;
    });

    src.update();
    QCOMPARE(counter, 1);
    src.update();
    QCOMPARE(counter, 2);

    signals.disconnectAll();
    src.update();
    QCOMPARE(counter, 2);
}

QTEST_MAIN(SignalsListTest)
