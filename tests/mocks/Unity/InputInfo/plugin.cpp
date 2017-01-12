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

// Qt
#include <QtQml>

// self
#include "plugin.h"

// local
#include "qdeclarativeinputdevicemodel_p.h"
#include "mockcontroller.h"

static QObject *backendProvider(QQmlEngine *engine, QJSEngine *scriptEngine)
{
    Q_UNUSED(engine)
    Q_UNUSED(scriptEngine)
    return MockController::instance();
}

void InputInfoPlugin::registerTypes(const char *uri)
{
    int major = 0;
    int minor = 1;
    qmlRegisterType<QDeclarativeInputDeviceModel>(uri, major, minor, "InputDeviceModel");
    qmlRegisterType<QInputDevice>(uri, major, minor, "InputInfo");

    // We can't register the MockInputDeviceBackend directly because QML wants to delete singletons on its own
    // Given that MockInputDeviceBackend is a Q_GLOBAL_STATIC it will also be cleaned up by other Qt internals
    // This leads to a double-free on shutdown. So let's add a proxy to control the MockBackend through QML:
    // MockController
    qmlRegisterSingletonType<MockController>(uri, major, minor, "MockInputDeviceBackend", backendProvider);
}

void InputInfoPlugin::initializeEngine(QQmlEngine *engine, const char *uri)
{
    QQmlExtensionPlugin::initializeEngine(engine, uri);

    if (qEnvironmentVariableIsSet("UNITY_MOCK_DESKTOP")) {
        MockController::instance()->addMockDevice("/mouse0", QInputDevice::Mouse);
        MockController::instance()->addMockDevice("/kbd0", QInputDevice::Keyboard);
    }
}
