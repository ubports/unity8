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

    m_initialProperties.insert("emptyText", "You have no more outstanding messages.");
    m_initialProperties.insert("highlightFollowsCurrentItem", false);
}

QUrl IndicatorClientMessaging::iconComponentSource() const
{
    return QUrl("qrc:/indicatorsclient/qml/DefaultIndicatorIcon.qml");
}

QUrl IndicatorClientMessaging::pageComponentSource() const
{
    return QUrl("qrc:/indicatorsclient/qml/MessagingIndicatorPage.qml");
}
