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

#include "indicatorclient_common.h"

#include <QUrl>
#include <QtPlugin>
#include <QResource>
#include <QDebug>
#include <QFileInfo>
#include <QDir>
#include <QQmlEngine>
#include <QQmlContext>
#include <QJsonObject>

#include <qdbusmenumodel.h>
#include <qdbusactiongroup.h>
#include <qstateaction.h>

//TODO: load this property dynamically
#define TARGET_DEVICE           "phone"

IndicatorClientCommon::IndicatorClientCommon(QObject *parent)
    : QObject(parent),
      m_visible(false),
      m_priority(0)
{
}

IndicatorClientCommon::~IndicatorClientCommon()
{
    shutdown();
}

void IndicatorClientCommon::init(const QSettings& settings)
{
    setId(settings.value("Indicator Service/Name").toString());
    QString dbusService = settings.value("Indicator Service/DBusName").toString();
    QString objectPath = settings.value("Indicator Service/ObjectPath").toString();

    m_initialProperties.clear();
    m_initialProperties.insert("title", m_title);
    m_initialProperties.insert("busType", 1);
    m_initialProperties.insert("busName", dbusService);
    m_initialProperties.insert("objectPath", objectPath);
}

void IndicatorClientCommon::shutdown()
{
}

QString IndicatorClientCommon::identifier() const
{
    return m_identifier;
}

void IndicatorClientCommon::setId(const QString &identifier)
{
    if (identifier != m_identifier) {
        m_identifier = identifier;
        Q_EMIT identifierChanged(m_identifier);
    }
}

QString IndicatorClientCommon::title() const
{
    return m_title;
}

void IndicatorClientCommon::setTitle(const QString &title)
{
    if (title != m_title) {
        m_title = title;
        Q_EMIT titleChanged(m_title);
    }
}

QString IndicatorClientCommon::description() const
{
    return m_description;
}

void IndicatorClientCommon::setDescription(const QString &description)
{
    if (description != m_description) {
        m_description = description;
        Q_EMIT titleChanged(m_description);
    }
}

int IndicatorClientCommon::priority() const
{
    return m_priority;
}

void IndicatorClientCommon::setPriority(int priority)
{
    if (priority != m_priority) {
        m_priority = priority;
        Q_EMIT priorityChanged(m_priority);
    }
}

bool IndicatorClientCommon::visible() const
{
    return m_visible;
}

void IndicatorClientCommon::setVisible(bool visible)
{
    if (visible != m_visible) {
        m_visible = visible;
        Q_EMIT visibleChanged(m_visible);
    }
}

QString IndicatorClientCommon::label() const
{
    return m_label;
}

void IndicatorClientCommon::setLabel(const QString &label)
{
    if (label != m_label) {
        m_label = label;
        Q_EMIT labelChanged(m_label);
    }
}

QUrl IndicatorClientCommon::iconComponentSource() const
{
    return QUrl("qrc:/indicatorsclient/qml/DefaultIndicatorIcon.qml");
}

QUrl IndicatorClientCommon::pageComponentSource() const
{
    return QUrl("qrc:/indicatorsclient/qml/DefaultIndicatorPage.qml");
}

IndicatorClientInterface::PropertiesMap IndicatorClientCommon::initialProperties()
{
    return m_initialProperties;
}
