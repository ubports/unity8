/*
 * Copyright (C) 2012, 2013 Canonical, Ltd.
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

TestUtil::TestUtil(QObject *parent)
    : QObject(parent)
    , m_targetWindow(0)
    , m_touchDevice(0)
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
            const QString qmlName = className.left(className.indexOf("_QMLTYPE_"));
            result = qmlName == name;
            metaObject = metaObject->superClass();
        }
    }
    return result;
}

TouchEventSequenceWrapper *TestUtil::touchEvent()
{
    ensureTargetWindow();
    ensureTouchDevice();

    return new TouchEventSequenceWrapper(
            QTest::touchEvent(m_targetWindow, m_touchDevice, /* autoCommit */ false));
}

void TestUtil::ensureTargetWindow()
{
    if (!m_targetWindow)
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
