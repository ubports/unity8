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
 *
 * Authored by: Daniel d'Andrada <daniel.dandrada@canonical.com>
 */

#include <QtTest/QtTest>

#include <AxisVelocityCalculator.h>

class FakeTimeSource : public UG_PREPEND_NAMESPACE(TimeSource) {
public:
    FakeTimeSource() : m_value(0) {}

    qint64 msecsSinceReference() override {
        return m_value;
    }

    void setMsecsSinceReference(qint64 time) {
        m_value = time;
    }

    void increaseMsecsSinceReference(qint64 time) {
        m_value += time;
    }

private:
    qint64 m_value;
};

class tst_AxisVelocityCalculator : public QObject
{
    Q_OBJECT
private Q_SLOTS:
    void init(); // called right before each and every test function is executed
    void cleanup(); // called right after each and every test function is executed

    void simpleSamples();
    void noSamples();
    void overflowSamples();
    void average();

private:
    AxisVelocityCalculator *velCalc;
    QSharedPointer<FakeTimeSource> fakeTimeSource;
};

void tst_AxisVelocityCalculator::init()
{
    fakeTimeSource.reset(new FakeTimeSource);

    velCalc = new AxisVelocityCalculator;
    velCalc->setTimeSource(fakeTimeSource);
}

void tst_AxisVelocityCalculator::cleanup()
{
    delete velCalc;
    fakeTimeSource.reset();
}

void tst_AxisVelocityCalculator::simpleSamples()
{
    qreal pos = 0;

    velCalc->setTrackedPosition(pos);
    velCalc->reset();

    fakeTimeSource->setMsecsSinceReference(10);
    pos += 20;
    velCalc->setTrackedPosition(pos);

    fakeTimeSource->setMsecsSinceReference(20);
    pos += 20;
    velCalc->setTrackedPosition(pos);

    fakeTimeSource->setMsecsSinceReference(30);
    pos += 20;
    velCalc->setTrackedPosition(pos);

    qreal velocity = velCalc->calculate();

    QCOMPARE(velocity, 2.0f);
}

void tst_AxisVelocityCalculator::noSamples()
{
    float velocity = velCalc->calculate();

    QCOMPARE(velocity, 0.0f);
}

void tst_AxisVelocityCalculator::overflowSamples()
{
    qreal pos = 0;

    velCalc->setTrackedPosition(pos);
    velCalc->reset();

    for (int i = 0; i < 1000; ++i) {
        fakeTimeSource->increaseMsecsSinceReference(10);
        pos += 20;
        velCalc->setTrackedPosition(pos);
    }

    /* overwrite all existing samples with faster ones */
    for (int i = 0; i < AxisVelocityCalculator::MAX_SAMPLES; ++i) {
        fakeTimeSource->increaseMsecsSinceReference(10);
        pos += 40;
        velCalc->setTrackedPosition(pos);
    }

    float velocity = velCalc->calculate();

    /* check that the calculated velocity correspond to the latest, faster, samples */
    QCOMPARE(velocity, 4.0f);
}

void tst_AxisVelocityCalculator::average()
{
    qreal pos = 0;

    velCalc->setTrackedPosition(pos);
    velCalc->reset();

    fakeTimeSource->increaseMsecsSinceReference(10);
    pos += 20;
    velCalc->setTrackedPosition(pos);

    fakeTimeSource->increaseMsecsSinceReference(10);
    pos += 20;
    velCalc->setTrackedPosition(pos);

    /* the last sample is an erratic one and would yield a big velocity if
       considered isolatedly */
    fakeTimeSource->increaseMsecsSinceReference(10);
    pos += 100;
    velCalc->setTrackedPosition(pos);

    float velocity = velCalc->calculate();

    /* calculated velocity is lower than the one from the last sample */
    QVERIFY(velocity < 9.0f);

    /* but it's higher the the slow samples */
    QVERIFY(velocity > 2.5f);
}

QTEST_MAIN(tst_AxisVelocityCalculator)

#include "tst_AxisVelocityCalculator.moc"
