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

#include "HomeKeyWatcher.h"

#include <QTest>
#include <QSignalSpy>


namespace UnityUtil {
class FakeElapsedTimer : public AbstractElapsedTimer {
public:
    static qint64 msecsSinceEpoch;

    FakeElapsedTimer() { start(); }

    void start() override { m_msecsSinceReference = msecsSinceEpoch; }
    qint64 msecsSinceReference() const override { return m_msecsSinceReference; }
    qint64 elapsed() const override { return msecsSinceEpoch - m_msecsSinceReference; }

private:
    qint64 m_msecsSinceReference;
};
qint64 FakeElapsedTimer::msecsSinceEpoch = 0;

class FakeTimer : public AbstractTimer
{
    Q_OBJECT
public:
    FakeTimer(QObject *parent = nullptr);

    void update();
    qint64 nextTimeoutTime() const { return m_nextTimeoutTime; }

    int interval() const override;
    void setInterval(int msecs) override;
    void start() override;
    bool isSingleShot() const override;
    void setSingleShot(bool value) override;
private:
    int m_interval;
    bool m_singleShot;
    qint64 m_nextTimeoutTime;
};

class FakeTimerFactory : public AbstractTimerFactory
{
public:
    FakeTimerFactory();
    virtual ~FakeTimerFactory();

    void updateTime(qint64 targetTime);

    AbstractTimer *create(QObject *parent = nullptr) override;
    QList<QPointer<FakeTimer>> timers;
};
} // namespace UnityUtil

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
    QTest::newRow("isolated long press") << 1000 << 200 << 1000 << 0;
}

void HomeKeyWatcherTest::touchTapTouch()
{
    QFETCH(int, silenceBeforeTap);
    QFETCH(int, tapDuration);
    QFETCH(int, silenceAfterTap);
    QFETCH(int, expectedActivatedCount);
    HomeKeyWatcher homeKeyWatcher(m_fakeTimerFactory->create(), new FakeElapsedTimer);
    QSignalSpy activatedSpy(&homeKeyWatcher, &HomeKeyWatcher::activated);
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
        QKeyEvent keyEvent(QEvent::KeyPress, Qt::Key_Super_L, Qt::NoModifier);
        homeKeyWatcher.update(&keyEvent);
    }
    int tapTime = 0;
    while (tapTime < tapDuration) {
        passTime(10);
        tapTime += 10;
        if (tapTime + 10 >= tapDuration) {
            QKeyEvent keyEvent(QEvent::KeyRelease, Qt::Key_Super_L, Qt::NoModifier);
            homeKeyWatcher.update(&keyEvent);
        } else {
            QKeyEvent keyEvent(QEvent::KeyPress, Qt::Key_Super_L, Qt::NoModifier, QString(), true /*autorepeat*/);
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
    QSignalSpy activatedSpy(&homeKeyWatcher, &HomeKeyWatcher::activated);
    QVERIFY(activatedSpy.isValid());

    {
        QTouchEvent touchEvent(QEvent::TouchBegin);
        homeKeyWatcher.update(&touchEvent);
    }
    passTime(1000);
    {
        QKeyEvent keyEvent(QEvent::KeyPress, Qt::Key_Super_L, Qt::NoModifier);
        homeKeyWatcher.update(&keyEvent);
    }
    passTime(100);
    {
        QKeyEvent keyEvent(QEvent::KeyRelease, Qt::Key_Super_L, Qt::NoModifier);
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

/////////////////////////////////// FakeTimer //////////////////////////////////

FakeTimer::FakeTimer(QObject *parent)
    : UnityUtil::AbstractTimer(parent)
    , m_interval(0)
    , m_singleShot(true)
{
}

void FakeTimer::update()
{
    if (!isRunning()) {
        return;
    }

    if (m_nextTimeoutTime <= FakeElapsedTimer::msecsSinceEpoch) {
        if (isSingleShot()) {
            stop();
        } else {
            m_nextTimeoutTime += interval();
        }
        Q_EMIT timeout();
    }
}

void FakeTimer::start()
{
    AbstractTimer::start();
    m_nextTimeoutTime = FakeElapsedTimer::msecsSinceEpoch + (qint64)interval();
}

int FakeTimer::interval() const
{
    return m_interval;
}

void FakeTimer::setInterval(int msecs)
{
    m_interval = msecs;
}

bool FakeTimer::isSingleShot() const
{
    return m_singleShot;
}

void FakeTimer::setSingleShot(bool value)
{
    m_singleShot = value;
}

/////////////////////////////////// FakeTimerFactory //////////////////////////////////

FakeTimerFactory::FakeTimerFactory()
{
}

FakeTimerFactory::~FakeTimerFactory()
{
    for (int i = 0; i < timers.count(); ++i) {
        FakeTimer *timer = timers[i].data();
        if (timer) {
            delete timer;
        }
    }
}

void FakeTimerFactory::updateTime(qint64 targetTime)
{
    qint64 minTimeoutTime = targetTime;

    for (int i = 0; i < timers.count(); ++i) {
        FakeTimer *timer = timers[i].data();
        if (timer && timer->isRunning() && timer->nextTimeoutTime() < minTimeoutTime) {
            minTimeoutTime = timer->nextTimeoutTime();
        }
    }

    FakeElapsedTimer::msecsSinceEpoch = minTimeoutTime;

    for (int i = 0; i < timers.count(); ++i) {
        FakeTimer *timer = timers[i].data();
        if (timer) {
            timer->update();
        }
    }

    if (FakeElapsedTimer::msecsSinceEpoch < targetTime) {
        updateTime(targetTime);
    }
}

AbstractTimer *FakeTimerFactory::create(QObject *parent)
{
    FakeTimer *fakeTimer = new FakeTimer(parent);

    timers.append(fakeTimer);

    return fakeTimer;
}

QTEST_GUILESS_MAIN(HomeKeyWatcherTest)

#include "HomeKeyWatcherTest.moc"
