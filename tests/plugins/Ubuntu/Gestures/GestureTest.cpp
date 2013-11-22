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

#include <qpa/qwindowsysteminterface.h>
#include <QQmlEngine>
#include <QQuickView>

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
    m_view = new QQuickView(0);
    m_view->setResizeMode(QQuickView::SizeRootObjectToView);
    m_view->resize(600, 600);
    m_view->engine()->addImportPath(QLatin1String(UBUNTU_GESTURES_PLUGIN_DIR));
}

void GestureTest::cleanup()
{
    delete m_view;
    m_view = nullptr;
}
