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

#include "GestureTest.h"

#include <PressedOutsideNotifier.h>

#include <QQuickItem>
#include <QQuickView>
#include <QtTest>

class tst_PressedOutsideNotifier: public GestureTest
{
    Q_OBJECT
public:
    tst_PressedOutsideNotifier();
private Q_SLOTS:
    void init() override; // called right before each and every test function is executed

    void touchOutsideAreaTriggersSignal();
    void touchInsideAreaHasNoEffect();
    void mousePressOutsideAreaTriggersSignal();
    void mousePresssInsideAreaHasNoEffect();
    void nothingHappensWhileDisabled();

private:
    QQuickItem *m_blueRect;
    PressedOutsideNotifier *m_notifier;
};

tst_PressedOutsideNotifier::tst_PressedOutsideNotifier()
    : GestureTest(QStringLiteral("tst_PressedOutsideNotifier.qml"))
{
}

void tst_PressedOutsideNotifier::init()
{
    GestureTest::init();

    m_blueRect = m_view->rootObject()->findChild<QQuickItem*>("blueRect");
    Q_ASSERT(m_blueRect != nullptr);

    m_notifier =
        m_view->rootObject()->findChild<PressedOutsideNotifier*>("pressedOutsideNotifier");
    Q_ASSERT(m_notifier != nullptr);
}

void tst_PressedOutsideNotifier::touchOutsideAreaTriggersSignal()
{
    // half-way towards the top-left corner of the blueRect.
    // Therefore, still outside it.
    QPoint touch0 = QPoint(m_blueRect->x() * 0.5, m_blueRect->y() * 0.5);

    QSignalSpy pressedOutsideSpy(m_notifier, &PressedOutsideNotifier::pressedOutside);

    QTest::touchEvent(m_view, m_device)
        .press(0, touch0);

    qApp->processEvents();

    QCOMPARE(pressedOutsideSpy.count(), 1);

    QTest::touchEvent(m_view, m_device)
        .release(0, touch0);
}

void tst_PressedOutsideNotifier::touchInsideAreaHasNoEffect()
{
    QPoint touch0 = QPoint(m_blueRect->x() + m_blueRect->width()*0.5,
                           m_blueRect->y() + m_blueRect->height()*0.5);

    QSignalSpy pressedOutsideSpy(m_notifier, &PressedOutsideNotifier::pressedOutside);

    QTest::touchEvent(m_view, m_device)
        .press(0, touch0);

    qApp->processEvents();

    QCOMPARE(pressedOutsideSpy.count(), 0);

    QTest::touchEvent(m_view, m_device)
        .release(0, touch0);
}

void tst_PressedOutsideNotifier::mousePressOutsideAreaTriggersSignal()
{
    QPoint mousePos= QPoint(m_blueRect->x() * 0.5, m_blueRect->y() * 0.5);

    QSignalSpy pressedOutsideSpy(m_notifier, &PressedOutsideNotifier::pressedOutside);

    QTest::mousePress(m_view, Qt::LeftButton, 0 /*modifiers*/, mousePos);

    qApp->processEvents();

    QCOMPARE(pressedOutsideSpy.count(), 1);

    QTest::mouseRelease(m_view, Qt::LeftButton, 0 /*modifiers*/, mousePos);
}

void tst_PressedOutsideNotifier::mousePresssInsideAreaHasNoEffect()
{
    QPoint mousePos = QPoint(m_blueRect->x() + m_blueRect->width()*0.5,
                             m_blueRect->y() + m_blueRect->height()*0.5);

    QSignalSpy pressedOutsideSpy(m_notifier, &PressedOutsideNotifier::pressedOutside);

    QTest::mousePress(m_view, Qt::LeftButton, 0 /*modifiers*/, mousePos);

    qApp->processEvents();

    QCOMPARE(pressedOutsideSpy.count(), 0);

    QTest::mouseRelease(m_view, Qt::LeftButton, 0 /*modifiers*/, mousePos);
}

void tst_PressedOutsideNotifier::nothingHappensWhileDisabled()
{
    QPoint touch0 = QPoint(m_blueRect->x() * 0.5, m_blueRect->y() * 0.5);

    QSignalSpy pressedOutsideSpy(m_notifier, &PressedOutsideNotifier::pressedOutside);

    m_notifier->setEnabled(false);

    QTest::touchEvent(m_view, m_device)
        .press(0, touch0);

    qApp->processEvents();

    QCOMPARE(pressedOutsideSpy.count(), 0);

    QTest::touchEvent(m_view, m_device)
        .release(0, touch0);
}

QTEST_MAIN(tst_PressedOutsideNotifier)

#include "tst_PressedOutsideNotifier.moc"
