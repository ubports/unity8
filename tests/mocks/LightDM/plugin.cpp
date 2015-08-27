/*
 * Copyright (C) 2014, 2015 Canonical, Ltd.
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

#include "plugin.h"
#include <DBusGreeter.h>
#include <DBusGreeterList.h>
#include "MockGreeter.h"
#include "MockUsersModel.h"
#include <libusermetricsoutput/ColorTheme.h>
#include <libusermetricsoutput/UserMetrics.h>
#include <QLightDM/UsersModel>

#include <QAbstractItemModel>
#include <QDBusConnection>
#include <QtQml/qqml.h>

static QObject *greeter_provider(QQmlEngine *engine, QJSEngine *scriptEngine)
{
    Q_UNUSED(engine)
    Q_UNUSED(scriptEngine)

    MockGreeter *greeter = new MockGreeter;
    new DBusGreeter(greeter, "/");
    new DBusGreeterList(greeter, "/list");

    return greeter;
}

static QObject *users_provider(QQmlEngine *engine, QJSEngine *scriptEngine)
{
    Q_UNUSED(engine)
    Q_UNUSED(scriptEngine)
    return new MockUsersModel;
}

static QObject *infographic_provider(QQmlEngine *engine, QJSEngine *scriptEngine)
{
    Q_UNUSED(engine)
    Q_UNUSED(scriptEngine)
    return UserMetricsOutput::UserMetrics::getInstance();
}

void IntegratedLightDMPlugin::registerTypes(const char *uri)
{
    qmlRegisterType<QAbstractItemModel>();
    qmlRegisterType<UserMetricsOutput::ColorTheme>();

    Q_ASSERT(uri == QLatin1String("IntegratedLightDM"));
    qRegisterMetaType<QLightDM::Greeter::MessageType>("QLightDM::Greeter::MessageType");
    qRegisterMetaType<QLightDM::Greeter::PromptType>("QLightDM::Greeter::PromptType");
    qmlRegisterSingletonType<MockGreeter>(uri, 0, 1, "Greeter", greeter_provider);
    qmlRegisterSingletonType<MockUsersModel>(uri, 0, 1, "Users", users_provider);
    qmlRegisterUncreatableType<QLightDM::UsersModel>(uri, 0, 1, "UserRoles", "Type is not instantiable");
    qmlRegisterSingletonType<UserMetricsOutput::UserMetrics>(uri, 0, 1, "Infographic", infographic_provider);
}
