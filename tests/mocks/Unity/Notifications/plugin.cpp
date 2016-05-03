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
 *
 * Authors:
 *      Mirco Mueller <mirco.mueller@canonical.com>
 */

#include "plugin.h"
#include "MockActionModel.h"
#include "MockNotification.h"
#include "MockNotificationModel.h"

#include <QtQml/qqml.h>

static QObject* modelProvider(QQmlEngine* /* engine */, QJSEngine* /* scriptEngine */)
{
    return new MockNotificationModel;
}

void TestNotificationPlugin::registerTypes(const char* uri)
{
    // @uri Unity.Notifications
    qmlRegisterType<MockNotification>(uri, 1, 0, "Notification");
    qmlRegisterSingletonType<MockNotificationModel>(uri, 1, 0, "Model", modelProvider);
    qmlRegisterType<ActionModel>(uri, 1, 0, "ActionModel");
}
