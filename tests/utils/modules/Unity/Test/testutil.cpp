/*
 * Copyright (C) 2012, 2013, 2014 Canonical, Ltd.
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


#include "testutil.h"

#include <qpa/qwindowsysteminterface.h>
#include <QtGui/QGuiApplication>
#include <QQuickView>
#include <private/qquickbehavior_p.h>
#include <private/qquickanimation_p.h>

// UbuntuGestures lib
#include <UbuntuGestures/ubuntugesturesglobal.h>
#include <UbuntuGestures/private/touchregistry_p.h>
#include <UbuntuGestures/private/timer_p.h>

UG_USE_NAMESPACE

TestUtil::TestUtil(QObject *parent)
    : QObject(parent)
    , m_targetWindow(0)
    , m_touchDevice(0)
    , m_putFakeTimerFactoryInTouchRegistry(false)
{
}

TestUtil::~TestUtil()
{
}

bool
TestUtil::isInstanceOf(QObject *obj, QString name)
{
    if (!obj) return false;
    bool result = obj->inherits(name.toUtf8());
    if (!result) {
        const QMetaObject *metaObject = obj->metaObject();
        while (!result && metaObject) {
            const QString className = metaObject->className();
            QString qmlName = className.left(className.indexOf("_QMLTYPE_"));
            result = qmlName == name;
            // test for known namespaces
            if (!result) {
                // remove UbuntuGestures and UbuntuToolkit namespace
                qmlName = qmlName.remove(QString("UbuntuGestures::"));
                result = qmlName == name;
            }
            if (!result) {
                qmlName = qmlName.remove(QString("UbuntuToolkit::"));
                result = qmlName == name;
            }
            metaObject = metaObject->superClass();
        }
    }
    return result;
}

void
TestUtil::waitForBehaviors(QObject *obj)
{
    if (!obj) return;

    Q_FOREACH(auto c, obj->children()) {
        if (auto *b = dynamic_cast<QQuickBehavior*>(c)) {
            if (b->animation()) {
                QTRY_COMPARE(b->animation()->isRunning(), false);
            }
        }
        waitForBehaviors(c);
    }
}

TouchEventSequenceWrapper *TestUtil::touchEvent(QQuickItem *item)
{
    ensureTargetWindow();
    ensureTouchDevice();

    // Tests can be *very* slow to run and we don't want things timing out because
    // of that. So give it fake timers to use (they will never time out)
    if (!m_putFakeTimerFactoryInTouchRegistry) {
        TouchRegistry::instance()->setTimerFactory(new FakeTimerFactory);
        m_putFakeTimerFactoryInTouchRegistry = true;
    }

    return new TouchEventSequenceWrapper(
            QTest::touchEvent(m_targetWindow, m_touchDevice, /* autoCommit */ false), item);
}

void TestUtil::ensureTargetWindow()
{
    if (!m_targetWindow && !QGuiApplication::topLevelWindows().isEmpty())
        m_targetWindow = QGuiApplication::topLevelWindows()[0];
}

void TestUtil::ensureTouchDevice()
{
    if (!m_touchDevice) {
        m_touchDevice = new QTouchDevice;
        m_touchDevice->setType(QTouchDevice::TouchScreen);
        QWindowSystemInterface::registerTouchDevice(m_touchDevice);
    }
}
