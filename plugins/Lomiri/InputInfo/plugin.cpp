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
#include <QtQml/qqml.h>

// self
#include "plugin.h"

// local
#include "qdeclarativeinputdevicemodel_p.h"

void InputInfoPlugin::registerTypes(const char *uri)
{
    int major = 0;
    int minor = 1;
    qmlRegisterType<QDeclarativeInputDeviceModel>(uri, major, minor, "InputDeviceModel");
    qmlRegisterType<QInputDevice>(uri, major, minor, "InputInfo");
}
