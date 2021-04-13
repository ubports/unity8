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
    // Save all keys we care about from the QSettings object.  It's annoying
    // that we can't just copy the object.
    m_settings.clear();
    Q_FOREACH(const QString& key, settings.allKeys()) {
        if (key.endsWith(QLatin1String("/Position")) || key.endsWith(QLatin1String("/ObjectPath"))) {
            m_settings.insert(key, settings.value(key));
        }
    }

    setId(settings.value(QStringLiteral("Indicator Service/Name")).toString());

    const QString actionObjectPath = settings.value(QStringLiteral("Indicator Service/ObjectPath")).toString();

    QVariantMap properties;
    properties.insert(QStringLiteral("busType"), 1);
    properties.insert(QStringLiteral("busName"), busName);
    properties.insert(QStringLiteral("actionsObjectPath"), actionObjectPath);
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

void Indicator::setProfile(const QString& profile)
{
    QVariant pos = m_settings.value(profile + "/Position");
    if (!pos.isValid())
        pos = m_settings.value(QStringLiteral("Indicator Service/Position"), QVariant::fromValue(0));
    setPosition(pos.toInt());

    const QString menuObjectPath = m_settings.value(profile + "/ObjectPath").toString();
    QVariantMap map = m_properties.toMap();
    map.insert(QStringLiteral("menuObjectPath"), menuObjectPath);
    setIndicatorProperties(map);
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
