/*
 * Copyright (C) 2013,2015 Canonical, Ltd.
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

#include <qpa/qwindowsysteminterface.h>
#include <QQmlEngine>
#include <QQuickView>
#include <QtTest>

#include <Timer.h>
#include <TouchRegistry.h>

using namespace UbuntuGestures;

GestureTest::GestureTest(const QString &qmlFilename)
    : QObject(), m_device(nullptr), m_view(nullptr), m_qmlFilename(qmlFilename)
{
}

void GestureTest::initTestCase()
{
    if (!m_device) {
        m_device = new QTouchDevice;
        m_device->setType(QTouchDevice::TouchScreen);
        QWindowSystemInterface::registerTouchDevice(m_device);
    }
}

void GestureTest::init()
{
    m_view = new QQuickView;
    m_view->setResizeMode(QQuickView::SizeRootObjectToView);
    m_view->setSource(QUrl::fromLocalFile(m_qmlFilename));
    m_view->show();
    QVERIFY(QTest::qWaitForWindowExposed(m_view));
    QVERIFY(m_view->rootObject() != 0);

    m_fakeTimerFactory = new FakeTimerFactory;

    m_touchRegistry = TouchRegistry::instance();
    m_touchRegistry->setTimerFactory(m_fakeTimerFactory);
    m_view->installEventFilter(m_touchRegistry);

    qApp->processEvents();
}

void GestureTest::cleanup()
{
    m_view->removeEventFilter(m_touchRegistry);
    delete m_touchRegistry;
    m_touchRegistry = nullptr;

    // TouchRegistry will take down the timer factory along with him
    // delete m_fakeTimerFactory;
    m_fakeTimerFactory = nullptr;

    delete m_view;
    m_view = nullptr;
}

////////////////////////// TouchMemento /////////////////////////////

TouchMemento::TouchMemento(const QTouchEvent *touchEvent)
    : touchPointStates(touchEvent->touchPointStates()), touchPoints(touchEvent->touchPoints())
{

}

bool TouchMemento::containsTouchWithId(int touchId) const
{
    for (int i = 0; i < touchPoints.count(); ++i) {
        if (touchPoints.at(i).id() == touchId) {
            return true;
        }
    }
    return false;
}

////////////////////////// DummyItem /////////////////////////////

DummyItem::DummyItem(QQuickItem *parent)
    : QQuickItem(parent)
{
    touchEventHandler = defaultTouchEventHandler;
    mousePressEventHandler = defaultMouseEventHandler;
    mouseMoveEventHandler = defaultMouseEventHandler;
    mouseReleaseEventHandler = defaultMouseEventHandler;
    mouseDoubleClickEventHandler = defaultMouseEventHandler;
}

void DummyItem::touchEvent(QTouchEvent *event)
{
    touchEvents.append(TouchMemento(event));
    touchEventHandler(event);
}

void DummyItem::mousePressEvent(QMouseEvent *event)
{
    mousePressEventHandler(event);
}

void DummyItem::mouseMoveEvent(QMouseEvent *event)
{
    mouseMoveEventHandler(event);
}

void DummyItem::mouseReleaseEvent(QMouseEvent *event)
{
    mouseReleaseEventHandler(event);
}

void DummyItem::mouseDoubleClickEvent(QMouseEvent *event)
{
    mouseDoubleClickEventHandler(event);
}

void DummyItem::defaultTouchEventHandler(QTouchEvent *event)
{
    event->accept();
}

void DummyItem::defaultMouseEventHandler(QMouseEvent *event)
{
    event->accept();
}
