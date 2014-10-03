/*
 * Copyright (C) 2014 Canonical, Ltd.
 *
 * This program is free software: you can redistribute it and/or modify it under
 * the terms of the GNU Lesser General Public License version 3, as published by
 * the Free Software Foundation.
 *
 * This program is distributed in the hope that it will be useful, but WITHOUT
 * ANY WARRANTY; without even the implied warranties of MERCHANTABILITY,
 * SATISFACTORY QUALITY, or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
 * Lesser General Public License for more details.
 *
 * You should have received a copy of the GNU Lesser General Public License
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.
 */

#include "orientationlock.h"

#include <QDBusConnection>
#include <QDBusInterface>

OrientationLock::OrientationLock(QObject *parent)
    : QObject(parent)
    , m_enabled(false)
    , m_savedOrientation(Qt::PortraitOrientation)
{
    m_systemSettings = g_settings_new("com.ubuntu.touch.system");
    g_signal_connect(m_systemSettings, "changed::rotation-lock",
                     G_CALLBACK(OrientationLock::onEnabledChangedProxy), this);
    m_enabled = g_settings_get_boolean(m_systemSettings, "rotation-lock");
}

OrientationLock::~OrientationLock()
{
    g_signal_handlers_disconnect_by_data(m_systemSettings, this);
    g_object_unref(m_systemSettings);
}

bool OrientationLock::enabled() const
{
    return m_enabled;
}

Qt::ScreenOrientation OrientationLock::savedOrientation() const
{
    return m_savedOrientation;
}

void OrientationLock::onEnabledChangedProxy(GSettings */*settings*/, const gchar */*key*/, gpointer data)
{
    OrientationLock* _this = static_cast<OrientationLock*>(data);
    _this->onEnabledChanged();
}

void OrientationLock::onEnabledChanged()
{
    const bool enabled = g_settings_get_boolean(m_systemSettings, "rotation-lock");
    if (m_enabled != enabled) {
        m_enabled = enabled;
        Q_EMIT enabledChanged();
    }
}

void OrientationLock::setSavedOrientation(const Qt::ScreenOrientation orientation)
{
    if (orientation == m_savedOrientation) {
        return;
    }

    m_savedOrientation = orientation;

    //TODO - save value with dbus to persist over sessions
    Q_EMIT savedOrientationChanged();
}
