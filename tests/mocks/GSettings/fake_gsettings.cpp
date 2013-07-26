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

struct GSettingsSchemaQmlPrivate {
    QByteArray id;
    QByteArray path;
};

struct GSettingsQmlPrivate {
    GSettingsSchemaQml *schema;
};

GSettingsControllerQml* GSettingsControllerQml::s_controllerInstance = 0;

GSettingsControllerQml::GSettingsControllerQml() {
}

GSettingsControllerQml::~GSettingsControllerQml() {
    s_controllerInstance = 0;
}

GSettingsControllerQml* GSettingsControllerQml::instance()  {
    if(!s_controllerInstance) {
        s_controllerInstance = new GSettingsControllerQml();
    }
    return s_controllerInstance;
}

void GSettingsControllerQml::registerSettingsObject(GSettingsQml *obj) {
    m_registeredGSettings.append(obj);
}

void GSettingsControllerQml::setPictureUri(const QString &str) {
    Q_FOREACH (GSettingsQml *obj, m_registeredGSettings) {
        obj->setPictureUri(str);
    }
}

GSettingsSchemaQml::GSettingsSchemaQml(QObject *parent): QObject(parent) {
    priv = new GSettingsSchemaQmlPrivate;
}

GSettingsSchemaQml::~GSettingsSchemaQml() {
    delete priv;
}

QByteArray GSettingsSchemaQml::id() const {
    return priv->id;
}

void GSettingsSchemaQml::setId(const QByteArray &id) {
    if (!priv->id.isEmpty()) {
        qWarning("GSettings.schema.id may only be set on construction");
        return;
    }

    priv->id = id;
}

QByteArray GSettingsSchemaQml::path() const {
    return priv->path;
}

void GSettingsSchemaQml::setPath(const QByteArray &path) {
    if (!priv->path.isEmpty()) {
        qWarning("GSettings.schema.path may only be set on construction");
        return;
    }

    priv->path = path;
}

GSettingsQml::GSettingsQml(QObject *parent): QObject(parent) {
    priv = new GSettingsQmlPrivate;
    priv->schema = new GSettingsSchemaQml(this);
    GSettingsControllerQml::instance()->registerSettingsObject(this);
}

GSettingsQml::~GSettingsQml() {
    delete priv;
}

GSettingsSchemaQml * GSettingsQml::schema() const {
    return priv->schema;
}

QString GSettingsQml::pictureUri() const {
    return m_pictureUri;
}

void GSettingsQml::setPictureUri(const QString &str) {
    if (str != m_pictureUri) {
        m_pictureUri = str;
        Q_EMIT pictureUriChanged(m_pictureUri);
    }
}
