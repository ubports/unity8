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
#include <QDebug>

GSettingsControllerQml* GSettingsControllerQml::s_controllerInstance = 0;

GSettingsControllerQml::GSettingsControllerQml() {
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

void GSettingsControllerQml::registerSettingsObject(GSettingsQml *obj) {
    m_registeredGSettings.append(obj);
}

void GSettingsControllerQml::unRegisterSettingsObject(GSettingsQml *obj) {
    m_registeredGSettings.removeOne(obj);
}

void GSettingsControllerQml::setPictureUri(const QByteArray &schemaId, const QString &str)
{
    if (m_pictureUri[schemaId] != str) {
        m_pictureUri[schemaId] = str;

        Q_FOREACH (GSettingsQml *obj, m_registeredGSettings) {
            if (obj->schema()->id() == schemaId) {
                Q_EMIT obj->pictureUriChanged(str);
            }
        }
    }
}

QString GSettingsControllerQml::pictureUri(const QByteArray &schemaId) const
{
    return m_pictureUri.value(schemaId, "");
}

void GSettingsControllerQml::setUsageMode(const QByteArray &schemaId, const QString &str)
{
    if (m_usageMode[schemaId] != str) {
        m_usageMode[schemaId] = str;

        Q_FOREACH (GSettingsQml *obj, m_registeredGSettings) {
            if (obj->schema()->id() == schemaId) {
                Q_EMIT obj->usageModeChanged(str);
            }
        }
    }
}

QString GSettingsControllerQml::usageMode(const QByteArray &schemaId) const
{
    return m_usageMode.value(schemaId, "phone");
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
    Q_EMIT idChanged(id);
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

GSettingsQml::GSettingsQml(QObject *parent): QObject(parent) {
    m_schema = new GSettingsSchemaQml(this);
    GSettingsControllerQml::instance()->registerSettingsObject(this);
}

GSettingsQml::~GSettingsQml() {
    GSettingsControllerQml::instance()->unRegisterSettingsObject(this);
}

GSettingsSchemaQml * GSettingsQml::schema() const {
    return m_schema;
}

void GSettingsQml::setPictureUri(const QString &str) {
    GSettingsControllerQml::instance()->setPictureUri(m_schema->id(), str);
}

QString GSettingsQml::pictureUri() const {
    return  GSettingsControllerQml::instance()->pictureUri(m_schema->id());
}

void GSettingsQml::setUsageMode(const QString &str) {
    GSettingsControllerQml::instance()->setUsageMode(m_schema->id(), str);
}

QString GSettingsQml::usageMode() const {
    return  GSettingsControllerQml::instance()->usageMode(m_schema->id());

}

