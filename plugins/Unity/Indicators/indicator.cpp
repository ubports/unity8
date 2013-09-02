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
 *
 * Authors:
 *      Renato Araujo Oliveira Filho <renato@canonical.com>
 */

#include "indicator.h"

#include <QStringList>

Indicator::Indicator(QObject *parent)
    : QObject(parent),
      m_position(0)
{
}

Indicator::~Indicator()
{
}

void Indicator::init(const QString& busName, const QSettings& settings)
{
    setId(settings.value("Indicator Service/Name").toString());
    setPosition(settings.value("Indicator Service/Position", QVariant::fromValue(0)).toInt());

    QString actionObjectPath = settings.value("Indicator Service/ObjectPath").toString();

    QVariantMap mapMenuObjectPaths;
    Q_FOREACH(const QString& childGroup, settings.childGroups())
    {
        if (childGroup == "Indicator Service")
            continue;

        QString menuPath = childGroup+"/ObjectPath";
        if (settings.contains(menuPath))
        {
            mapMenuObjectPaths[childGroup] = settings.value(menuPath).toString();
        }
    }

    QVariantMap properties;
    properties.clear();
    properties.insert("busType", 1);
    properties.insert("busName", busName);
    properties.insert("actionsObjectPath", actionObjectPath);
    properties.insert("menuObjectPaths", mapMenuObjectPaths);
    setIndicatorProperties(properties);
}

QString Indicator::identifier() const
{
    return m_identifier;
}

void Indicator::setId(const QString &identifier)
{
    if (identifier != m_identifier) {
        m_identifier = identifier;
        Q_EMIT identifierChanged(m_identifier);
    }
}

int Indicator::position() const
{
    return m_position;
}

void Indicator::setPosition(int position)
{
    if (position != m_position) {
        m_position = position;
        Q_EMIT positionChanged(m_position);
    }
}

QVariant Indicator::indicatorProperties() const
{
    return m_properties;
}

void Indicator::setIndicatorProperties(const QVariant &properties)
{
    if (m_properties != properties)
    {
        m_properties = properties;
        Q_EMIT indicatorPropertiesChanged(m_properties);
    }
}
