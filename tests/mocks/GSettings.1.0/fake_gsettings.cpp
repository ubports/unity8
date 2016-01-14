/*
 * Copyright 2013 Canonical Ltd.
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

#include "fake_gsettings.h"

#include <QList>

GSettingsControllerQml* GSettingsControllerQml::s_controllerInstance = 0;

GSettingsControllerQml::GSettingsControllerQml()
    : m_usageMode("Staged")
    , m_autohideLauncher(false)
    , m_launcherWidth(8)
{
}

GSettingsControllerQml::~GSettingsControllerQml() {
    s_controllerInstance = 0;
}

GSettingsControllerQml* GSettingsControllerQml::instance()  {
    if (!s_controllerInstance) {
        s_controllerInstance = new GSettingsControllerQml();
    }
    return s_controllerInstance;
}

QString GSettingsControllerQml::pictureUri() const
{
    return m_pictureUri;
}

void GSettingsControllerQml::setPictureUri(const QString &str)
{
    if (str != m_pictureUri) {
        m_pictureUri = str;
        Q_EMIT pictureUriChanged(m_pictureUri);
    }
}

QString GSettingsControllerQml::usageMode() const
{
    return m_usageMode;
}

void GSettingsControllerQml::setUsageMode(const QString &usageMode)
{
    if (usageMode != m_usageMode) {
        m_usageMode = usageMode;
        Q_EMIT usageModeChanged(m_usageMode);
    }
}

qint64 GSettingsControllerQml::lockedOutTime() const
{
    return m_lockedOutTime;
}

void GSettingsControllerQml::setLockedOutTime(qint64 timestamp)
{
    if (m_lockedOutTime != timestamp) {
        m_lockedOutTime = timestamp;
        Q_EMIT lockedOutTimeChanged(m_lockedOutTime);
    }
}

QStringList GSettingsControllerQml::lifecycleExemptAppids() const
{
    return m_lifecycleExemptAppids;
}

void GSettingsControllerQml::setLifecycleExemptAppids(const QStringList &appIds)
{
    if (m_lifecycleExemptAppids != appIds) {
        m_lifecycleExemptAppids = appIds;
        Q_EMIT lifecycleExemptAppidsChanged(m_lifecycleExemptAppids);
    }
}

bool GSettingsControllerQml::autohideLauncher() const
{
    return m_autohideLauncher;
}

void GSettingsControllerQml::setAutohideLauncher(bool autohideLauncher)
{
    if (m_autohideLauncher != autohideLauncher) {
        m_autohideLauncher = autohideLauncher;
        Q_EMIT autohideLauncherChanged(autohideLauncher);
    }
}

int GSettingsControllerQml::launcherWidth() const
{
    return m_launcherWidth;
}

void GSettingsControllerQml::setLauncherWidth(int launcherWidth)
{
    if (m_launcherWidth != launcherWidth) {
        m_launcherWidth = launcherWidth;
        Q_EMIT launcherWidthChanged(launcherWidth);
    }
}

GSettingsSchemaQml::GSettingsSchemaQml(QObject *parent): QObject(parent) {
}

QByteArray GSettingsSchemaQml::id() const {
    return m_id;
}

void GSettingsSchemaQml::setId(const QByteArray &id) {
    if (!m_id.isEmpty()) {
        qWarning("GSettings.schema.id may only be set on construction");
        return;
    }

    m_id = id;
}

QByteArray GSettingsSchemaQml::path() const {
    return m_path;
}

void GSettingsSchemaQml::setPath(const QByteArray &path) {
    if (!m_path.isEmpty()) {
        qWarning("GSettings.schema.path may only be set on construction");
        return;
    }

    m_path = path;
}

GSettingsQml::GSettingsQml(QObject *parent)
    : QObject(parent)
{
    m_schema = new GSettingsSchemaQml(this);
    connect(GSettingsControllerQml::instance(), &GSettingsControllerQml::pictureUriChanged,
            this, &GSettingsQml::pictureUriChanged);
    connect(GSettingsControllerQml::instance(), &GSettingsControllerQml::usageModeChanged,
            this, &GSettingsQml::usageModeChanged);
    connect(GSettingsControllerQml::instance(), &GSettingsControllerQml::lockedOutTimeChanged,
            this, &GSettingsQml::lockedOutTimeChanged);
    connect(GSettingsControllerQml::instance(), &GSettingsControllerQml::lifecycleExemptAppidsChanged,
            this, &GSettingsQml::lifecycleExemptAppidsChanged);
    connect(GSettingsControllerQml::instance(), &GSettingsControllerQml::autohideLauncherChanged,
            this, &GSettingsQml::autohideLauncherChanged);
    connect(GSettingsControllerQml::instance(), &GSettingsControllerQml::launcherWidthChanged,
            this, &GSettingsQml::launcherWidthChanged);
}

GSettingsSchemaQml * GSettingsQml::schema() const {
    return m_schema;
}

QString GSettingsQml::pictureUri() const
{
    if (m_schema->id() == "org.gnome.desktop.background") {
        return GSettingsControllerQml::instance()->pictureUri();
    } else {
        return "";
    }
}

void GSettingsQml::setPictureUri(const QString &str)
{
    if (m_schema->id() == "org.gnome.desktop.background") {
        GSettingsControllerQml::instance()->setPictureUri(str);
    }
}

QString GSettingsQml::usageMode() const
{
    if (m_schema->id() == "com.canonical.Unity8") {
        return GSettingsControllerQml::instance()->usageMode();
    } else {
        return "";
    }
}

void GSettingsQml::setUsageMode(const QString &usageMode)
{
    if (m_schema->id() == "com.canonical.Unity8") {
        GSettingsControllerQml::instance()->setUsageMode(usageMode);
    }
}

qint64 GSettingsQml::lockedOutTime() const
{
    if (m_schema->id() == "com.canonical.Unity8.Greeter") {
        return GSettingsControllerQml::instance()->lockedOutTime();
    } else {
        return 0;
    }
}

void GSettingsQml::setLockedOutTime(qint64 timestamp)
{
    if (m_schema->id() == "com.canonical.Unity8.Greeter") {
        GSettingsControllerQml::instance()->setLockedOutTime(timestamp);
    }
}

QStringList GSettingsQml::lifecycleExemptAppids() const
{
    if (m_schema->id() == "com.canonical.qtmir") {
        return GSettingsControllerQml::instance()->lifecycleExemptAppids();
    } else {
        return QStringList();
    }
}

bool GSettingsQml::autohideLauncher() const
{
    if (m_schema->id() == "com.canonical.Unity8") {
        return GSettingsControllerQml::instance()->autohideLauncher();
    } else {
        return false;
    }
}

int GSettingsQml::launcherWidth() const
{
    if (m_schema->id() == "com.canonical.Unity8") {
        return GSettingsControllerQml::instance()->launcherWidth();
    } else {
        return false;
    }
}

void GSettingsQml::setLifecycleExemptAppids(const QStringList &appIds)
{
    if (m_schema->id() == "com.canonical.qtmir") {
        GSettingsControllerQml::instance()->setLifecycleExemptAppids(appIds);
    }
}

void GSettingsQml::setAutohideLauncher(bool autohideLauncher)
{
    if (m_schema->id() == "com.canonical.Unity8") {
        GSettingsControllerQml::instance()->setAutohideLauncher(autohideLauncher);
    }
}

void GSettingsQml::setLauncherWidth(int launcherWidth)
{
    if (m_schema->id() == "com.canonical.Unity8") {
        GSettingsControllerQml::instance()->setLauncherWidth(launcherWidth);
    }
}
