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

#include "indicatorclient_network.h"
#include "networkagent.h"

#include <QUrl>
#include <QtQml>
#include <QtPlugin>

#include <qdbusmenumodel.h>
#include <qdbusactiongroup.h>
#include <qstateaction.h>

IndicatorClientNetwork::IndicatorClientNetwork(QObject *parent)
    : IndicatorClientCommon(parent),
      m_action(0)
{
    setTitle("Networks");
    setPriority(IndicatorPriority::NETWORK);

    m_timedAnimation.setInterval(500);
    connect(&m_timedAnimation, SIGNAL(timeout()), SLOT(animationNextFrame()));
}

IndicatorClientNetwork::~IndicatorClientNetwork()
{
}

void IndicatorClientNetwork::init(const QSettings& settings)
{
    IndicatorClientCommon::init(settings);
    Q_INIT_RESOURCE(indicatorclient_network);

    qmlRegisterType<NetworkAgent>("NetworkSettings", 0, 1, "NetworkAgent");
    setIcon(QUrl("image://gicon/wifi-none"));
}

QQmlComponent *IndicatorClientNetwork::createComponent(QQmlEngine *engine, QObject *parent) const
{
    return new QQmlComponent(engine, QUrl("qrc:/indicatorclient/network/qml/NetworkPage.qml"), parent);
}

IndicatorClientInterface::WidgetsMap IndicatorClientNetwork::widgets()
{
    static WidgetsMap w;
    if (w.isEmpty()) {
        w.insert("unity.widget.systemsettings.tablet.sectiontitle", QUrl("qrc:/indicatorclient/network/qml/WifiSection.qml"));
        w.insert("unity.widgets.systemsettings.tablet.wifisection", QUrl("qrc:/indicatorclient/network/qml/WifiSection.qml"));
        w.insert("unity.widgets.systemsettings.tablet.accesspoint", QUrl("qrc:/indicatorclient/network/qml/Accesspoint.qml"));
    }
    return w;
}

bool IndicatorClientNetwork::parseRootElement(const QString &type, QMap<int, QVariant> data)
{
    if (type == "com.canonical.indicator.root.network") {
        if (m_action != 0) {
            delete m_action;
        }

        QVariant action = data[QDBusMenuModel::Action];
        m_action = actionGroup()->action(action.toString());
        if (m_action->isValid()) {
            updateNetworkStatus(m_action->state());
        }
        connect(m_action, SIGNAL(stateChanged(QVariant)), SLOT(updateNetworkStatus(QVariant)));
        return true;
    } else {
        return false;
    }
}

QString IndicatorClientNetwork::getIconBasedOnSingal(uint signal) const
{
    if (signal == 0) {
        return "nm-signal-00";
    } else if (signal <= 25) {
        return "nm-signal-25";
    } else if (signal <= 50) {
        return "nm-signal-50";
    } else if (signal <= 75) {
        return "nm-signal-75";
    } else {
        return "nm-signal-100";
    }
}

void IndicatorClientNetwork::animationNextFrame()
{
    static int frame = 0;
    QString iconName;
    switch (frame) {
    case 0:
        iconName = "nm-signal-00";
        break;
    case 1:
        iconName = "nm-signal-25";
        break;
    case 2:
        iconName = "nm-signal-50";
        break;
    case 3:
        iconName = "nm-signal-75";
        break;
    case 4:
        iconName = "nm-signal-100";
        break;
    }

    if (frame < 4) {
        frame++;
    } else {
        frame = 0;
    }
    setIcon(QUrl("image://gicon/" + iconName));
}

void IndicatorClientNetwork::updateNetworkStatus(const QVariant &state)
{
    if (state.isValid()) {
        // (uuu)
        // - Device type
        // - Connection state
        // - Extended state
        QVariantList states = state.toList();
        if (states.size() == 3) {
            QString iconName;
            uint connectionState = states[1].toUInt();
            switch (connectionState)
            {
            case 3: // NM_ACTIVE_CONNECTION_STATE_DEACTIVATING
            case 1: // NM_ACTIVE_CONNECTION_STATE_ACTIVATING
                m_timedAnimation.start();
                iconName = "nm-signal-100";
                break;
            case 2: // NM_ACTIVE_CONNECTION_STATE_ACTIVATED
                m_timedAnimation.stop();
                iconName = getIconBasedOnSingal(states[2].toUInt());
                break;
            case 0: // NM_ACTIVE_CONNECTION_STATE_UNKNOWN
            default:
                m_timedAnimation.stop();
                iconName = "wifi-none";
                break;
            }

            setIcon(QUrl("image://gicon/" + iconName));
            return;
        } else {
            qWarning() << "Invalid network root state value";
            m_timedAnimation.stop();
            setIcon(QUrl());
        }
    } else {
        qWarning() << "Invalid network root state";
    }
}
