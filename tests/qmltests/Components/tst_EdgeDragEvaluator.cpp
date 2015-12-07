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

#include <functional>
#include <QtTest>
#include <QObject>
#include <QQuickView>
#include <QQmlEngine>
#include <QQuickItem>

// Ubuntu.Gestures plugin
#include <AxisVelocityCalculator.h>
#include <Direction.h>
#include <Timer>

using namespace UbuntuGestures;

class tst_EdgeDragEvaluator: public QObject
{
    Q_OBJECT
public:
    tst_EdgeDragEvaluator() {}
private Q_SLOTS:
    void initTestCase(); // will be called before the first test function is executed
    void cleanupTestCase(); // will be called after the last test function was executed.

    void init(); // called right before each and every test function is executed
    void cleanup(); // called right after each and every test function is executed

    void horizontalDirection();
    void horizontalDirection_data();

private:
    void drag(qreal &pos, qreal distance, qreal speed);

    QQuickView *createView();
    QQuickView *m_view;
    FakeTimer *m_fakeTimer;
    QSharedPointer<FakeTimeSource> m_fakeTimeSource;
    AxisVelocityCalculator *m_dragEvaluator;
};


void tst_EdgeDragEvaluator::initTestCase()
{
    m_view = 0;
}

void tst_EdgeDragEvaluator::cleanupTestCase()
{
}

void tst_EdgeDragEvaluator::init()
{

    m_view = createView();
    m_view->setSource(QUrl::fromLocalFile(TEST_DIR"/tst_EdgeDragEvaluator.qml"));
    m_view->show();
    QVERIFY(QTest::qWaitForWindowExposed(m_view));
    QVERIFY(m_view->rootObject() != 0);
    qApp->processEvents();

    m_fakeTimeSource.reset(new FakeTimeSource);
    m_fakeTimer = new FakeTimer(m_fakeTimeSource);

    m_dragEvaluator =
        m_view->rootObject()->findChild<AxisVelocityCalculator*>("edgeDragEvaluator");
    QVERIFY(m_dragEvaluator);
    m_dragEvaluator->setTimeSource(m_fakeTimeSource);
}

void tst_EdgeDragEvaluator::cleanup()
{
    m_dragEvaluator = nullptr;

    delete m_view;
    m_view = 0;

    delete m_fakeTimer;
    m_fakeTimer = 0;

    m_fakeTimeSource.reset();
}

QQuickView *tst_EdgeDragEvaluator::createView()
{
    QQuickView *window = new QQuickView(0);
    window->setResizeMode(QQuickView::SizeRootObjectToView);
    window->engine()->addImportPath(QLatin1String(TEST_DIR));

    return window;
}

void tst_EdgeDragEvaluator::drag(qreal &pos, qreal distance, qreal speed)
{
    int numSteps = 10;
    qreal distanceStep = distance / ((qreal)numSteps);
    int timeStep = qAbs(distanceStep / speed);

    for (int i = 0; i < numSteps; ++i) {
        m_fakeTimeSource->m_msecsSinceReference += timeStep;
        pos += distanceStep;
        m_dragEvaluator->setTrackedPosition(pos);
    }
}

void tst_EdgeDragEvaluator::horizontalDirection()
{
    qreal maxDragDistance = 100.;
    qreal speedThreshold = 100.;
    qreal speedThresholdMs = speedThreshold / 1000.;
    QFETCH(qreal, dragDirection);

    m_dragEvaluator->setProperty("maxDragDistance", QVariant::fromValue(maxDragDistance));
    m_dragEvaluator->setProperty("dragThreshold", QVariant::fromValue(maxDragDistance * 0.5));
    m_dragEvaluator->setProperty("speedThreshold", QVariant::fromValue(speedThreshold));

    // If direction is "Horizontal" it means it can drag leftwards or rightwards
    m_dragEvaluator->setProperty("direction", QVariant::fromValue((int)Direction::Horizontal));

    qreal pos = 0.;
    m_dragEvaluator->setTrackedPosition(pos);

    // Go far beyond dragThreshold
    drag(pos, maxDragDistance * 0.75 * dragDirection /*distance*/, speedThresholdMs * 0.5 /*speed*/);

    // Then come back a bit, getting close to dragThreshold
    drag(pos, -maxDragDistance * 0.20 * dragDirection /*distance*/, speedThresholdMs * 0.5 /*speed*/);

    QVariant shouldAutoComplete;
    bool ok = QMetaObject::invokeMethod(m_dragEvaluator, "shouldAutoComplete", Qt::DirectConnection,
            Q_RETURN_ARG(QVariant, shouldAutoComplete));
    QVERIFY(ok);

    // It should not autocomplete because the current negative velocity (speedThresholdMs * 0.5)
    // is bigger (in absolute terms) than the minimum negative velocity at this position needed to
    // cancel autocompletion (speedThreshold * 0.1)
    QCOMPARE(shouldAutoComplete.toBool(), false);
}

void tst_EdgeDragEvaluator::horizontalDirection_data()
{
    QTest::addColumn<qreal>("dragDirection");

    QTest::newRow("right") << 1.;
    QTest::newRow("left")  << -1.;
}

QTEST_MAIN(tst_EdgeDragEvaluator)

#include "tst_EdgeDragEvaluator.moc"
