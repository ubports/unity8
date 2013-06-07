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
 *      Olivier Tilloy <olivier.tilloy@canonical.com>
 */

#include "indicatorclient_messaging.h"

#include <QUrl>
#include <QtPlugin>

IndicatorClientMessaging::IndicatorClientMessaging(QObject *parent)
    : IndicatorClientCommon(parent)
{
    setTitle("Messages");
    setPriority(IndicatorPriority::MESSAGING);
}

IndicatorClientMessaging::~IndicatorClientMessaging()
{
}

void IndicatorClientMessaging::init(const QSettings& settings)
{
    IndicatorClientCommon::init(settings);
    Q_INIT_RESOURCE(indicatorclient_messaging);

    m_initialProperties.insert("emptyText", "You have no more outstanding messages.");
    m_initialProperties.insert("highlightFollowsCurrentItem", false);
}

QQmlComponent *IndicatorClientMessaging::createComponent(QQmlEngine *engine, QObject *parent) const
{
    return new QQmlComponent(engine, QUrl("qrc:/indicatorsclient/messaging/qml/messagingplugin.qml"), parent);
}

IndicatorClientInterface::WidgetsMap IndicatorClientMessaging::widgets()
{
    static WidgetsMap w;
    if (w.isEmpty()) {
        w.insert("com.canonical.indicator.messages.messageitem", QUrl("qrc:/indicatorsclient/messaging/qml/MessageItem.qml"));
        w.insert("com.canonical.indicator.messages.snapdecision", QUrl("qrc:/indicatorsclient/messaging/qml/MessageItem.qml"));
        w.insert("com.canonical.indicator.messages.sourceitem", QUrl("qrc:/indicatorsclient/messaging/qml/GroupedMessage.qml"));
    }
    return w;
}

