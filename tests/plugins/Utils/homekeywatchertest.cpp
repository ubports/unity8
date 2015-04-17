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

#include "homekeywatcher.h"

#include <QTest>
#include <QSignalSpy>

using namespace UnityUtil;

class HomeKeyWatcherTest : public QObject {
    Q_OBJECT
private Q_SLOTS:
    void init(); // called right before each and every test function is executed
    void cleanup(); // called right after each and every test function is executed

    void touchTapTouch_data();
    void touchTapTouch();

    void tapWhileTouching();

private:
    void passTime(qint64 timeSpanMs);

    FakeTimerFactory *m_fakeTimerFactory;
};

void HomeKeyWatcherTest::init()
{
    m_fakeTimerFactory = new FakeTimerFactory;
}

void HomeKeyWatcherTest::cleanup()
{
     delete m_fakeTimerFactory;
    m_fakeTimerFactory = nullptr;
}


void HomeKeyWatcherTest::passTime(qint64 timeSpanMs)
{
    qint64 finalTime = FakeElapsedTimer::msecsSinceEpoch + timeSpanMs;
    m_fakeTimerFactory->updateTime(finalTime);
}

void HomeKeyWatcherTest::touchTapTouch_data()
{
    QTest::addColumn<int>("silenceBeforeTap");
    QTest::addColumn<int>("tapDuration");
    QTest::addColumn<int>("silenceAfterTap");
    QTest::addColumn<int>("expectedActivatedCount");

    QTest::newRow("tap followed by touch") << 2000 << 50 << 10 << 0;
    QTest::newRow("touch, tap and touch") << 10 << 50 << 10 << 0;
    QTest::newRow("touch followed by tap") << 10 << 50 << 2000 << 0;
    QTest::newRow("touch followed by long tap") << 10 << 500 << 2000 << 0;
    QTest::newRow("isolated tap") << 1000 << 50 << 1000 << 1;
}

void HomeKeyWatcherTest::touchTapTouch()
{
    QFETCH(int, silenceBeforeTap);
    QFETCH(int, tapDuration);
    QFETCH(int, silenceAfterTap);
    QFETCH(int, expectedActivatedCount);
    HomeKeyWatcher homeKeyWatcher(m_fakeTimerFactory->create(), new FakeElapsedTimer);
    QSignalSpy activatedSpy(&homeKeyWatcher, SIGNAL(activated()));
    QVERIFY(activatedSpy.isValid());

    {
        QTouchEvent touchEvent(QEvent::TouchBegin);
        homeKeyWatcher.update(&touchEvent);
    }
    passTime(100);
    {
        QTouchEvent touchEvent(QEvent::TouchUpdate);
        homeKeyWatcher.update(&touchEvent);
    }
    passTime(100);
    {
        QTouchEvent touchEvent(QEvent::TouchEnd);
        homeKeyWatcher.update(&touchEvent);
    }

    passTime(silenceBeforeTap);

    {
        QKeyEvent keyEvent(QEvent::KeyPress, Qt::Key_Home, Qt::NoModifier);
        homeKeyWatcher.update(&keyEvent);
    }
    int tapTime = 0;
    while (tapTime < tapDuration) {
        passTime(10);
        tapTime += 10;
        if (tapTime + 10 >= tapDuration) {
            QKeyEvent keyEvent(QEvent::KeyRelease, Qt::Key_Home, Qt::NoModifier);
            homeKeyWatcher.update(&keyEvent);
        } else {
            QKeyEvent keyEvent(QEvent::KeyPress, Qt::Key_Home, Qt::NoModifier, QString(), true /*autorepeat*/);
            homeKeyWatcher.update(&keyEvent);
        }
    }

    passTime(silenceAfterTap);

    {
        QTouchEvent touchEvent(QEvent::TouchBegin);
        homeKeyWatcher.update(&touchEvent);
    }
    passTime(100);
    {
        QTouchEvent touchEvent(QEvent::TouchUpdate);
        homeKeyWatcher.update(&touchEvent);
    }
    passTime(100);
    {
        QTouchEvent touchEvent(QEvent::TouchEnd);
        homeKeyWatcher.update(&touchEvent);
    }
    passTime(1000);

    QCOMPARE(activatedSpy.count(), expectedActivatedCount);
}

void HomeKeyWatcherTest::tapWhileTouching()
{
    HomeKeyWatcher homeKeyWatcher(m_fakeTimerFactory->create(), new FakeElapsedTimer);
    QSignalSpy activatedSpy(&homeKeyWatcher, SIGNAL(activated()));
    QVERIFY(activatedSpy.isValid());

    {
        QTouchEvent touchEvent(QEvent::TouchBegin);
        homeKeyWatcher.update(&touchEvent);
    }
    passTime(1000);
    {
        QKeyEvent keyEvent(QEvent::KeyPress, Qt::Key_Home, Qt::NoModifier);
        homeKeyWatcher.update(&keyEvent);
    }
    passTime(100);
    {
        QKeyEvent keyEvent(QEvent::KeyRelease, Qt::Key_Home, Qt::NoModifier);
        homeKeyWatcher.update(&keyEvent);
    }
    passTime(1000);
    {
        QTouchEvent touchEvent(QEvent::TouchEnd);
        homeKeyWatcher.update(&touchEvent);
    }
    passTime(1000);


    QCOMPARE(activatedSpy.count(), 0);
}

QTEST_GUILESS_MAIN(HomeKeyWatcherTest)

#include "homekeywatchertest.moc"
