/*
 * Copyright 2013 Canonical Ltd.
 *
 * This program is free software; you can redistribute it and/or modify
 * it under the terms of the GNU Lesser General Public License as published by
 * the Free Software Foundation; version 3.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU Lesser General Public License for more details.
 *
 * You should have received a copy of the GNU Lesser General Public License
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.
 *
 * Authors:
 *      Nick Dedekind <nick.dedekind@canonical.com>
 */

#include "menucontentactivator.h"

#include <QtTest>
#include <QDebug>

class FakeTimer : public UnityIndicators::AbstractTimer
{
    Q_OBJECT
public:
    FakeTimer(QObject *parent = 0)
        : UnityIndicators::AbstractTimer(parent)
        , m_duration(0)
    {}

    int interval() const override { return m_duration; }
    void setInterval(int msecs) override { m_duration = msecs; }

    void emitTimeout() {
        if (isRunning()) {
            Q_EMIT timeout();
        }
    }
private:
    int m_duration;
};


class MenuConentActivatorTest : public QObject
{
    Q_OBJECT
private Q_SLOTS:
    void init() // called right before each and every test function is executed
    {
        m_fakeTimeSource = new FakeTimer(this);
        m_deltas.clear();
    }
    void cleanup() // called right after each and every test function is executed
    {
        delete m_fakeTimeSource;
        m_fakeTimeSource = 0;
    }

    /*
     * Tests the ordering of activation
     */
    void testContentActiveChange()
    {
        MenuContentActivator activator;
        activator.setContentTimer(m_fakeTimeSource);
        activator.setCount(10);
        activator.setBaseIndex(5);
        activator.restart();

        QCOMPARE(activator.isMenuContentActive(4), false);
        QCOMPARE(activator.isMenuContentActive(5), true); // always active at base index.
        QCOMPARE(activator.isMenuContentActive(6), false);

        m_fakeTimeSource->emitTimeout();
        QCOMPARE(activator.isMenuContentActive(4), false);
        QCOMPARE(activator.isMenuContentActive(5), true);
        QCOMPARE(activator.isMenuContentActive(6), true);
        QCOMPARE(activator.isMenuContentActive(7), false);

        m_fakeTimeSource->emitTimeout();
        QCOMPARE(activator.isMenuContentActive(3), false);
        QCOMPARE(activator.isMenuContentActive(4), true);
        QCOMPARE(activator.isMenuContentActive(5), true);
        QCOMPARE(activator.isMenuContentActive(6), true);
        QCOMPARE(activator.isMenuContentActive(7), false);

        m_fakeTimeSource->emitTimeout();
        QCOMPARE(activator.isMenuContentActive(3), false);
        QCOMPARE(activator.isMenuContentActive(4), true);
        QCOMPARE(activator.isMenuContentActive(5), true);
        QCOMPARE(activator.isMenuContentActive(6), true);
        QCOMPARE(activator.isMenuContentActive(7), true);
        QCOMPARE(activator.isMenuContentActive(8), false);

        m_fakeTimeSource->emitTimeout();
        QCOMPARE(activator.isMenuContentActive(2), false);
        QCOMPARE(activator.isMenuContentActive(3), true);
        QCOMPARE(activator.isMenuContentActive(4), true);
        QCOMPARE(activator.isMenuContentActive(5), true);
        QCOMPARE(activator.isMenuContentActive(6), true);
        QCOMPARE(activator.isMenuContentActive(7), true);
        QCOMPARE(activator.isMenuContentActive(8), false);

        m_fakeTimeSource->emitTimeout();
        QCOMPARE(activator.isMenuContentActive(2), false);
        QCOMPARE(activator.isMenuContentActive(3), true);
        QCOMPARE(activator.isMenuContentActive(4), true);
        QCOMPARE(activator.isMenuContentActive(5), true);
        QCOMPARE(activator.isMenuContentActive(6), true);
        QCOMPARE(activator.isMenuContentActive(7), true);
        QCOMPARE(activator.isMenuContentActive(8), true);
        QCOMPARE(activator.isMenuContentActive(9), false);

        m_fakeTimeSource->emitTimeout();
        QCOMPARE(activator.isMenuContentActive(1), false);
        QCOMPARE(activator.isMenuContentActive(2), true);
        QCOMPARE(activator.isMenuContentActive(3), true);
        QCOMPARE(activator.isMenuContentActive(4), true);
        QCOMPARE(activator.isMenuContentActive(5), true);
        QCOMPARE(activator.isMenuContentActive(6), true);
        QCOMPARE(activator.isMenuContentActive(7), true);
        QCOMPARE(activator.isMenuContentActive(8), true);
        QCOMPARE(activator.isMenuContentActive(9), false);

        m_fakeTimeSource->emitTimeout();
        QCOMPARE(activator.isMenuContentActive(1), false);
        QCOMPARE(activator.isMenuContentActive(2), true);
        QCOMPARE(activator.isMenuContentActive(3), true);
        QCOMPARE(activator.isMenuContentActive(4), true);
        QCOMPARE(activator.isMenuContentActive(5), true);
        QCOMPARE(activator.isMenuContentActive(6), true);
        QCOMPARE(activator.isMenuContentActive(7), true);
        QCOMPARE(activator.isMenuContentActive(8), true);
        QCOMPARE(activator.isMenuContentActive(9), true);
        QCOMPARE(activator.isMenuContentActive(10), false);

        m_fakeTimeSource->emitTimeout();
        QCOMPARE(activator.isMenuContentActive(0), false);
        QCOMPARE(activator.isMenuContentActive(1), true);
        QCOMPARE(activator.isMenuContentActive(2), true);
        QCOMPARE(activator.isMenuContentActive(3), true);
        QCOMPARE(activator.isMenuContentActive(4), true);
        QCOMPARE(activator.isMenuContentActive(5), true);
        QCOMPARE(activator.isMenuContentActive(6), true);
        QCOMPARE(activator.isMenuContentActive(7), true);
        QCOMPARE(activator.isMenuContentActive(8), true);
        QCOMPARE(activator.isMenuContentActive(9), true);
        QCOMPARE(activator.isMenuContentActive(10), false);

        m_fakeTimeSource->emitTimeout();
        QCOMPARE(activator.isMenuContentActive(-1), false);
        QCOMPARE(activator.isMenuContentActive(0), true);
        QCOMPARE(activator.isMenuContentActive(1), true);
        QCOMPARE(activator.isMenuContentActive(2), true);
        QCOMPARE(activator.isMenuContentActive(3), true);
        QCOMPARE(activator.isMenuContentActive(4), true);
        QCOMPARE(activator.isMenuContentActive(5), true);
        QCOMPARE(activator.isMenuContentActive(6), true);
        QCOMPARE(activator.isMenuContentActive(7), true);
        QCOMPARE(activator.isMenuContentActive(8), true);
        QCOMPARE(activator.isMenuContentActive(9), true);
        QCOMPARE(activator.isMenuContentActive(10), false);
    }

    /*
     * Tests the delta calculation for each timeout.
     */
    void testDelta()
    {
        MenuContentActivator activator;
        activator.setContentTimer(m_fakeTimeSource);
        activator.setCount(9);
        activator.setBaseIndex(3);

        connect(&activator, &MenuContentActivator::deltaChanged,
                this, &MenuConentActivatorTest::onDeltaChange);
        activator.restart();

        QCOMPARE(m_deltas, QList<int>()); // empty
        QCOMPARE(getIndexList(&activator), QList<int>()); // empty

        m_fakeTimeSource->emitTimeout();
        QCOMPARE(m_deltas, QList<int>() << 1);
        QCOMPARE(getIndexList(&activator), QList<int>() << 4);

        m_fakeTimeSource->emitTimeout();
        QCOMPARE(m_deltas, QList<int>() << 1 << -1);
        QCOMPARE(getIndexList(&activator), QList<int>() << 4 << 2);

        m_fakeTimeSource->emitTimeout();
        QCOMPARE(m_deltas, QList<int>() << 1 << -1 << 2);
        QCOMPARE(getIndexList(&activator), QList<int>() << 4 << 2 << 5);

        m_fakeTimeSource->emitTimeout();
        QCOMPARE(m_deltas, QList<int>() << 1 << -1 << 2 << -2);
        QCOMPARE(getIndexList(&activator), QList<int>() << 4 << 2 << 5 << 1);

        m_fakeTimeSource->emitTimeout();
        QCOMPARE(m_deltas, QList<int>() << 1 << -1 << 2 << -2 << 3);
        QCOMPARE(getIndexList(&activator), QList<int>() << 4 << 2 << 5 << 1 << 6);

        m_fakeTimeSource->emitTimeout();
        QCOMPARE(m_deltas, QList<int>() << 1 << -1 << 2 << -2 << 3 << -3);
        QCOMPARE(getIndexList(&activator), QList<int>() << 4 << 2 << 5 << 1 << 6 << 0);

        m_fakeTimeSource->emitTimeout();
        QCOMPARE(m_deltas, QList<int>() << 1 << -1 << 2 << -2 << 3 << -3 << 4);
        QCOMPARE(getIndexList(&activator), QList<int>() <<  4 << 2 << 5 << 1 << 6 << 0 << 7);

        m_fakeTimeSource->emitTimeout();
        QCOMPARE(m_deltas, QList<int>() << 1 << -1 << 2 << -2 << 3 << -3 << 4 << 5);
        QCOMPARE(getIndexList(&activator), QList<int>() << 4 << 2 << 5 << 1 << 6 << 0 << 7 << 8);

        m_fakeTimeSource->emitTimeout();
        QCOMPARE(m_deltas, QList<int>() << 1 << -1 << 2 << -2 << 3 << -3 << 4 << 5);
        QCOMPARE(getIndexList(&activator), QList<int>() << 4 << 2 << 5 << 1 << 6 << 0 << 7 << 8);
    }

    /*
     * Tests that changing the base index re-prioritizes the activation
     * around the base index.
     */
    void testBaseIndexChange()
    {
        MenuContentActivator activator;
        activator.setContentTimer(m_fakeTimeSource);
        activator.setCount(12);
        activator.setBaseIndex(5);
        activator.restart();

        m_fakeTimeSource->emitTimeout();
        m_fakeTimeSource->emitTimeout();
        QCOMPARE(activator.isMenuContentActive(3), false);
        QCOMPARE(activator.isMenuContentActive(4), true);
        QCOMPARE(activator.isMenuContentActive(5), true); // always active at base index.
        QCOMPARE(activator.isMenuContentActive(6), true);
        QCOMPARE(activator.isMenuContentActive(7), false);

        activator.setBaseIndex(8);
        QCOMPARE(activator.isMenuContentActive(3), false);
        QCOMPARE(activator.isMenuContentActive(4), true);
        QCOMPARE(activator.isMenuContentActive(5), true);
        QCOMPARE(activator.isMenuContentActive(6), true);
        QCOMPARE(activator.isMenuContentActive(7), false);
        QCOMPARE(activator.isMenuContentActive(8), true);
        QCOMPARE(activator.isMenuContentActive(9), false);

        m_fakeTimeSource->emitTimeout();
        QCOMPARE(activator.isMenuContentActive(3), false);
        QCOMPARE(activator.isMenuContentActive(4), true);
        QCOMPARE(activator.isMenuContentActive(5), true);
        QCOMPARE(activator.isMenuContentActive(6), true);
        QCOMPARE(activator.isMenuContentActive(7), false);
        QCOMPARE(activator.isMenuContentActive(8), true);
        QCOMPARE(activator.isMenuContentActive(9), true);
        QCOMPARE(activator.isMenuContentActive(10), false);

        m_fakeTimeSource->emitTimeout();
        QCOMPARE(activator.isMenuContentActive(3), false);
        QCOMPARE(activator.isMenuContentActive(4), true);
        QCOMPARE(activator.isMenuContentActive(5), true);
        QCOMPARE(activator.isMenuContentActive(6), true);
        QCOMPARE(activator.isMenuContentActive(7), true);
        QCOMPARE(activator.isMenuContentActive(8), true);
        QCOMPARE(activator.isMenuContentActive(9), true);
        QCOMPARE(activator.isMenuContentActive(10), false);

        m_fakeTimeSource->emitTimeout();
        QCOMPARE(activator.isMenuContentActive(3), false);
        QCOMPARE(activator.isMenuContentActive(4), true);
        QCOMPARE(activator.isMenuContentActive(5), true);
        QCOMPARE(activator.isMenuContentActive(6), true);
        QCOMPARE(activator.isMenuContentActive(7), true);
        QCOMPARE(activator.isMenuContentActive(8), true);
        QCOMPARE(activator.isMenuContentActive(9), true);
        QCOMPARE(activator.isMenuContentActive(10), true);
        QCOMPARE(activator.isMenuContentActive(11), false);
    }

    void onDeltaChange(int delta)
    {
        m_deltas << delta;
    }

private:
    QList<int> getIndexList(MenuContentActivator* activator)
    {
        QList<int> list;
        Q_FOREACH(int delta, m_deltas) {
            list << (activator->baseIndex() + delta);
        }
        return list;
    }

    FakeTimer* m_fakeTimeSource;
    QList<int> m_deltas;
};

QTEST_GUILESS_MAIN(MenuConentActivatorTest)
#include "MenuContentActivatorTest.moc"
