/*
 * Copyright 2015 Canonical Ltd.
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
 */

#include "mockcontroller.h"

#include "qinputdeviceinfo_mock_p.h"

#include <QQuickView>
#include <QQmlComponent>
#include <QQuickItem>
#include <paths.h>

MockController::MockController(QQmlEngine *engine)
{
    QQmlComponent component(engine);
    component.setData("import QtQuick 2.4; import Unity.InputInfo 0.1; InputWindow { }", ::qmlDirectory());
    QObject *myObject = component.create();
    QQuickItem *item = qobject_cast<QQuickItem*>(myObject);
    if (item) {
        auto window = new QQuickView();
        window->setTitle("Input");
        item->setParentItem(window->contentItem());
        window->setResizeMode(QQuickView::SizeRootObjectToView);
        window->setWidth(200);
        window->setHeight(100);
        window->show();
    }
}

MockController *MockController::instance(QQmlEngine *engine)
{
    static MockController* controller = new MockController(engine);
    return controller;
}

QInputDevice *MockController::addMockDevice(const QString &devicePath, QInputDevice::InputType type)
{
    return QInputDeviceManagerPrivate::instance()->addMockDevice(devicePath, type);
}

void MockController::removeDevice(const QString &devicePath)
{
    QInputDeviceManagerPrivate::instance()->removeDevice(devicePath);
}
