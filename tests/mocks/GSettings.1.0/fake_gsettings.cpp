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
    : m_disableHeight(false)
    , m_lockedOutTime(0)
    , m_usageMode("Staged")
    , m_autohideLauncher(false)
    , m_launcherWidth(8)
    , m_edgeDragWidth(2)
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

bool GSettingsControllerQml::disableHeight() const
{
    return m_disableHeight;
}

void GSettingsControllerQml::setDisableHeight(bool val)
{
    if (val != m_disableHeight) {
        m_disableHeight = val;
        Q_EMIT disableHeightChanged();
    }
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

uint GSettingsControllerQml::edgeDragWidth() const
{
    return m_edgeDragWidth;
}

void GSettingsControllerQml::setEdgeDragWidth(uint edgeDragWidth)
{
    if (m_edgeDragWidth != edgeDragWidth) {
        m_edgeDragWidth = edgeDragWidth;
        Q_EMIT edgeDragWidthChanged(edgeDragWidth);
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
    : QObject(parent),
      m_valid(false)
{
    m_schema = new GSettingsSchemaQml(this);
}

void GSettingsQml::classBegin()
{
}

void GSettingsQml::componentComplete()
{
    // Emulate what the real GSettings module does, and only return undefined
    // values until we are completed loading.
    m_valid = true;

    // FIXME: We should make this dynamic, instead of hard-coding all possible
    // properties in one object.  We should create properties based on the schema.
    connect(GSettingsControllerQml::instance(), &GSettingsControllerQml::disableHeightChanged,
            this, &GSettingsQml::disableHeightChanged);
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
    connect(GSettingsControllerQml::instance(), &GSettingsControllerQml::edgeDragWidthChanged,
            this, &GSettingsQml::edgeDragWidthChanged);

    Q_EMIT disableHeightChanged();
    Q_EMIT pictureUriChanged();
    Q_EMIT usageModeChanged();
    Q_EMIT lockedOutTimeChanged();
    Q_EMIT lifecycleExemptAppidsChanged();
    Q_EMIT autohideLauncherChanged();
    Q_EMIT launcherWidthChanged();
    Q_EMIT edgeDragWidthChanged();
}

GSettingsSchemaQml * GSettingsQml::schema() const {
    return m_schema;
}

QVariant GSettingsQml::disableHeight() const
{
    if (m_valid && m_schema->id() == "com.canonical.keyboard.maliit") {
        return GSettingsControllerQml::instance()->disableHeight();
    } else {
        return QVariant();
    }
}

void GSettingsQml::setDisableHeight(const QVariant &val)
{
    if (m_valid && m_schema->id() == "com.canonical.keyboard.maliit") {
        GSettingsControllerQml::instance()->setDisableHeight(val.toBool());
    }
}

QVariant GSettingsQml::pictureUri() const
{
    if (m_valid && m_schema->id() == "org.gnome.desktop.background") {
        return GSettingsControllerQml::instance()->pictureUri();
    } else {
        return QVariant();
    }
}

void GSettingsQml::setPictureUri(const QVariant &str)
{
    if (m_valid && m_schema->id() == "org.gnome.desktop.background") {
        GSettingsControllerQml::instance()->setPictureUri(str.toString());
    }
}

QVariant GSettingsQml::usageMode() const
{
    if (m_valid && m_schema->id() == "com.canonical.Unity8") {
        return GSettingsControllerQml::instance()->usageMode();
    } else {
        return QVariant();
    }
}

void GSettingsQml::setUsageMode(const QVariant &usageMode)
{
    if (m_valid && m_schema->id() == "com.canonical.Unity8") {
        GSettingsControllerQml::instance()->setUsageMode(usageMode.toString());
    }
}

QVariant GSettingsQml::lockedOutTime() const
{
    if (m_valid && m_schema->id() == "com.canonical.Unity8.Greeter") {
        return GSettingsControllerQml::instance()->lockedOutTime();
    } else {
        return QVariant();
    }
}

void GSettingsQml::setLockedOutTime(const QVariant &timestamp)
{
    if (m_valid && m_schema->id() == "com.canonical.Unity8.Greeter") {
        GSettingsControllerQml::instance()->setLockedOutTime(timestamp.value<qint64>());
    }
}

QVariant GSettingsQml::lifecycleExemptAppids() const
{
    if (m_valid && m_schema->id() == "com.canonical.qtmir") {
        return GSettingsControllerQml::instance()->lifecycleExemptAppids();
    } else {
        return QVariant();
    }
}

QVariant GSettingsQml::autohideLauncher() const
{
    if (m_valid && m_schema->id() == "com.canonical.Unity8") {
        return GSettingsControllerQml::instance()->autohideLauncher();
    } else {
        return QVariant();
    }
}

QVariant GSettingsQml::launcherWidth() const
{
    if (m_valid && m_schema->id() == "com.canonical.Unity8") {
        return GSettingsControllerQml::instance()->launcherWidth();
    } else {
        return QVariant();
    }
}

QVariant GSettingsQml::edgeDragWidth() const
{
    if (m_valid && m_schema->id() == "com.canonical.Unity8") {
        return GSettingsControllerQml::instance()->edgeDragWidth();
    } else {
        return QVariant();
    }
}

void GSettingsQml::setLifecycleExemptAppids(const QVariant &appIds)
{
    if (m_valid && m_schema->id() == "com.canonical.qtmir") {
        GSettingsControllerQml::instance()->setLifecycleExemptAppids(appIds.toStringList());
    }
}

void GSettingsQml::setAutohideLauncher(const QVariant &autohideLauncher)
{
    if (m_valid && m_schema->id() == "com.canonical.Unity8") {
        GSettingsControllerQml::instance()->setAutohideLauncher(autohideLauncher.toBool());
    }
}

void GSettingsQml::setLauncherWidth(const QVariant &launcherWidth)
{
    if (m_valid && m_schema->id() == "com.canonical.Unity8") {
        GSettingsControllerQml::instance()->setLauncherWidth(launcherWidth.toInt());
    }
}

void GSettingsQml::setEdgeDragWidth(const QVariant &edgeDragWidth)
{
    if (m_valid && m_schema->id() == "com.canonical.Unity8") {
        GSettingsControllerQml::instance()->setEdgeDragWidth(edgeDragWidth.toUInt());
    }
}
