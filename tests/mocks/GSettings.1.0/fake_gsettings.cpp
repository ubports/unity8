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
