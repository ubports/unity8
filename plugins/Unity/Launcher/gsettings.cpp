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

    const QString items = QStringLiteral("items");
    Q_FOREACH(const QString &entry, m_gSettings->get(items).toStringList()) {
        if (entry.startsWith(QLatin1String("application:///"))) {
            // convert legacy entries to new world appids
            QString appId = entry;
            // Transform "application://foobar.desktop" to "foobar"
            appId.remove(QRegExp(QStringLiteral("^application:///")));
            appId.remove(QRegExp(QStringLiteral(".desktop$")));
            storedApps << appId;
        } else if (entry.startsWith(QLatin1String("appid://"))) {
            QString appId = entry;
            appId.remove(QStringLiteral("appid://"));
            const QStringList splittedAppId = appId.split('/');
            if (splittedAppId.count() == 3) {
                // Strip current-user-version in case its there
                appId = splittedAppId.first() +  "_" + splittedAppId.at(1);
            }
            storedApps << appId;
        }
    }
    return storedApps;
}

void GSettings::setStoredApplications(const QStringList &storedApplications)
{
    QStringList gSettingsList;
    gSettingsList.reserve(storedApplications.count());
    Q_FOREACH(const QString &entry, storedApplications) {
        gSettingsList << QStringLiteral("appid://%1").arg(entry);
    }
    // GSettings will emit a changed signal to ourselves. Let's cache the items
    // and only forward the changed signal when the list did actually change.
    m_cachedItems = gSettingsList;
    m_gSettings->set(QStringLiteral("items"), gSettingsList);
}

void GSettings::onSettingsChanged(const QString &key)
{
    if (key == QLatin1String("items")) {
        const QStringList cachedItems = m_gSettings->get(QStringLiteral("items")).toStringList();
        if (m_cachedItems != cachedItems) {
            m_cachedItems = cachedItems;
            Q_EMIT changed();
        }
    }
}
