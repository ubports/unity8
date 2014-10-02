/*
 * Copyright 2014 Canonical Ltd.
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
 *      Michael Zanetti <michael.zanetti@canonical.com>
 */

#include "gsettings.h"

#include <QVariant>

GSettings::GSettings(QObject *parent):
    QObject(parent)
{
    m_gSettings = new QGSettings("com.canonical.Unity.Launcher", "/com/canonical/unity/launcher/", this);
    connect(m_gSettings, &QGSettings::changed, this, &GSettings::onSettingsChanged);
}

QStringList GSettings::storedApplications() const
{
    QStringList storedApps;

    Q_FOREACH(const QString &entry, m_gSettings->get("items").toStringList()) {
        if (entry.startsWith("application:///")) {
            // convert legacy entries to new world appids
            QString appId = entry;
            // Transform "application://foobar.desktop" to "foobar"
            appId.remove(QRegExp("^application:///"));
            appId.remove(QRegExp(".desktop$"));
            storedApps << appId;
        } else if (entry.startsWith("appid://")) {
            QString appId = entry;
            appId.remove("appid://");
            if (appId.split('/').count() == 3) {
                // Strip current-user-version in case its there
                appId = appId.split('/').first() +  "_" + appId.split('/').at(1);
            }
            storedApps << appId;
        }
    }
    return storedApps;
}

void GSettings::setStoredApplications(const QStringList &storedApplications)
{
    QStringList gSettingsList;
    Q_FOREACH(const QString &entry, storedApplications) {
        gSettingsList << QString("appid://%1").arg(entry);
    }
    m_gSettings->set("items", gSettingsList);
}

void GSettings::onSettingsChanged(const QString &key)
{
    if (key == "items") {
        Q_EMIT changed();
    }
}
