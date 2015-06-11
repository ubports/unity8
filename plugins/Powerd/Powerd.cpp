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
 *
 * Author: Michael Terry <michael.terry@canonical.com>
 */

#include "Powerd.h"
#include <QDBusPendingCall>
#include <QDBusConnection>

void autoBrightnessChanged(GSettings *settings, const gchar *key, Powerd * instance)
{
    const bool value = g_settings_get_boolean(settings, key);
    instance->performAsyncCall("userAutobrightnessEnable", {value});
}

void activityTimeoutChanged(GSettings *settings, const gchar *key, Powerd * instance)
{
    const int value = g_settings_get_int(settings, key);
    instance->performAsyncCall("setInactivityTimeouts", {value, -1});
}

void dimTimeoutChanged(GSettings *settings, const gchar *key, Powerd * instance)
{
    const int value = g_settings_get_int(settings, key);
    instance->performAsyncCall("setInactivityTimeouts", {-1, value});
}

Powerd::Powerd(QObject* parent)
  : QObject(parent),
    cachedStatus(Status::On)
{
    QDBusConnection::SM_BUSNAME().connect("com.canonical.Unity.Screen",
                                          "/com/canonical/Unity/Screen",
                                          "com.canonical.Unity.Screen",
                                          "DisplayPowerStateChange",
                                          this,
                                          SLOT(handleDisplayPowerStateChange(int, int)));

    systemSettings = g_settings_new("com.ubuntu.touch.system");
    g_signal_connect(systemSettings, "changed::auto-brightness", G_CALLBACK(autoBrightnessChanged), this);
    g_signal_connect(systemSettings, "changed::activity-timeout", G_CALLBACK(activityTimeoutChanged), this);
    g_signal_connect(systemSettings, "changed::dim-timeout", G_CALLBACK(dimTimeoutChanged), this);
    autoBrightnessChanged(systemSettings, "auto-brightness", this);
    activityTimeoutChanged(systemSettings, "activity-timeout", this);
    dimTimeoutChanged(systemSettings, "dim-timeout", this);
}

Powerd::~Powerd()
{
    g_signal_handlers_disconnect_by_data(systemSettings, this);
    g_object_unref(systemSettings);
}

Powerd::Status Powerd::status() const
{
    return cachedStatus;
}

void Powerd::handleDisplayPowerStateChange(int status, int reason)
{
    if (cachedStatus != (Status)status) {
        cachedStatus = (Status)status;
        Q_EMIT statusChanged((DisplayStateChangeReason)reason);
    }
}

void Powerd::performAsyncCall(const QString &method, const QVariantList &args)
{
    QDBusMessage msg = QDBusMessage::createMethodCall("com.canonical.Unity.Screen",
                                                      "/com/canonical/Unity/Screen",
                                                      "com.canonical.Unity.Screen",
                                                      method);
    msg.setArguments(args);
    QDBusConnection::SM_BUSNAME().asyncCall(msg);
}
