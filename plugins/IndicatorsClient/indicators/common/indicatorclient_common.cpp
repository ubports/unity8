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
      m_icon(""),
      m_visible(false),
      m_priority(0),
      m_model(0),
      m_actionGroup(0),
      m_action(0),
      m_component(0)
{
}

IndicatorClientCommon::~IndicatorClientCommon()
{
    shutdown();
}

void IndicatorClientCommon::init(const QSettings& settings)
{
    Q_INIT_RESOURCE(indicatorclient_common);

    setId(settings.value("Indicator Service/Name").toString());
    QString dbusService = settings.value("Indicator Service/DBusName").toString();
    QString objectPath = settings.value("Indicator Service/ObjectPath").toString();

    m_model = new QDBusMenuModel(this);
    m_model->setBusName(dbusService);
    m_model->setObjectPath(objectPath + "/" + TARGET_DEVICE);
    m_model->setBusType(DBusEnums::SessionBus);

    //keep track of any change in the model
    connect(m_model, SIGNAL(statusChanged(DBusEnums::ConnectionStatus)), SLOT(onModelChanged()));
    connect(m_model, SIGNAL(rowsInserted(QModelIndex,int,int)), SLOT(onModelChanged()));
    connect(m_model, SIGNAL(rowsRemoved(QModelIndex,int,int)), SLOT(onModelChanged()));
    connect(m_model, SIGNAL(dataChanged(QModelIndex,QModelIndex)), SLOT(onModelChanged()));

    m_actionGroup = new QDBusActionGroup(this);
    m_actionGroup->setBusType(m_model->busType());
    m_actionGroup->setBusName(m_model->busName());
    m_actionGroup->setObjectPath(objectPath);

    m_initialProperties.clear();
    m_initialProperties.insert("title", m_title);
    m_initialProperties.insert("busType", 1);
    m_initialProperties.insert("busName", dbusService);
    m_initialProperties.insert("objectPath", objectPath);

    m_actionGroup->start();
    m_model->start();
}

void IndicatorClientCommon::onModelChanged()
{
    DBusEnums::ConnectionStatus status = m_model->status();

    if (status == DBusEnums::Connected) {
        QModelIndex index = m_model->index(0);
        if (index.isValid()) {
            QVariant extra = m_model->data(index, QDBusMenuModel::Extra);
            QVariantMap extraMap = extra.toMap();
            if (extraMap.contains("canonical_type")) {
                QString type = extraMap["canonical_type"].toString();
                parseRootElement(type, m_model->itemData(index));
            }
        }
    } else {
        parseRootElement("", QMap<int, QVariant>());
    }
}

bool IndicatorClientCommon::parseRootElement(const QString &type, QMap<int, QVariant> data)
{
    if (type.isEmpty()) {
        return false;
    } else if (type != "com.canonical.indicator.root") {
        if (!type.startsWith("com.canonical.indicator.root")) {
            qWarning() << "indicator" << title() << "does not support root element";
        }
        return false;
    } else {
        if (m_action != 0) {
            delete m_action;
        }

        QVariant action = data[QDBusMenuModel::Action];
        m_action = m_actionGroup->action(action.toString());

        if (m_action->isValid()) {
            updateState(m_action->state());
        }
        QObject::connect(m_action, SIGNAL(stateChanged(QVariant)), this, SLOT(updateState(QVariant)));
        return true;
    }
}

void IndicatorClientCommon::updateState(const QVariant &state)
{
    if (state.isValid()) {
        // (sssb) : the current label, icon name, accessible name, and visibility state of the indicator.
        QVariantList states = state.toList();
        if (states.size() == 4) {
            setLabel(states[0].toString());
            setIcon(QUrl(states[1].toString()));
            setVisible(states[2].toBool());
            setAccessibleName(states[3].toString());
            return;
        }
    }

    setLabel("");
    setIcon(QUrl());
    setVisible(false);
    setAccessibleName("");
}

void IndicatorClientCommon::shutdown()
{
    delete m_component;
    m_component = 0;

    delete m_model;
    m_model = 0;

    delete m_action;
    m_action = 0;

    delete m_actionGroup;
    m_actionGroup = 0;
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

QUrl IndicatorClientCommon::icon() const
{
    if (!m_icon.isEmpty() && m_icon.scheme().isEmpty()) {
        return QString("image://gicon/") + QUrl::toPercentEncoding(m_icon.toString());
    } else {
        return m_icon;
    }
}

void IndicatorClientCommon::setIcon(const QUrl &icon)
{
    if (icon != m_icon) {
        m_icon = icon;
        Q_EMIT iconChanged(m_icon);
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

QString IndicatorClientCommon::accessibleName() const
{
    return m_accessibleName;
}

void IndicatorClientCommon::setAccessibleName(const QString &accesibleName)
{
    if (accesibleName != m_accessibleName) {
        m_accessibleName = accesibleName;
        Q_EMIT accessibleNameChanged(m_accessibleName);
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

QDBusActionGroup *IndicatorClientCommon::actionGroup() const
{
    return m_actionGroup;
}

QQmlComponent *IndicatorClientCommon::createComponent(QQmlEngine *engine, QObject *parent) const
{
    return new QQmlComponent(engine, QUrl("qrc:/indicatorsclient/qml/commonplugin.qml"), parent);
}

QQmlComponent *IndicatorClientCommon::component(QQmlEngine *engine, QObject *parent)
{
    if (m_component == 0) {
        m_component = createComponent(engine, parent);
    }
    return m_component;
}

IndicatorClientInterface::PropertiesMap IndicatorClientCommon::initialProperties()
{
    return m_initialProperties;
}

IndicatorClientInterface::WidgetsMap IndicatorClientCommon::widgets()
{
    // Register all basic/native widgets
    static WidgetsMap w;
    if (w.isEmpty()) {
        //TODO: use a generic name for volumecontrol widget (Slider)
        w.insert("unity.widgets.systemsettings.tablet.volumecontrol", QUrl("SliderMenu.qml"));
        w.insert("unity.widgets.systemsettings.tablet.switch", QUrl("SwitchMenu.qml"));

        w.insert("com.canonical.indicator.button", QUrl("ButtonMenu.qml"));
        w.insert("com.canonical.indicator.div", QUrl("DivMenu.qml"));
        w.insert("com.canonical.indicator.section", QUrl("MenuSection.qml"));
        w.insert("com.canonical.indicator.progress", QUrl("ProgressMenu.qml"));
        w.insert("com.canonical.indicator.slider", QUrl("SliderMenu.qml"));
        w.insert("com.canonical.indicator.switch", QUrl("SwitchMenu.qml"));
    }
    return w;
}
