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
    : IndicatorClientCommon(parent)
{
    setTitle("Networks");
    setPriority(IndicatorPriority::NETWORK);
}

IndicatorClientNetwork::~IndicatorClientNetwork()
{
}

void IndicatorClientNetwork::init(const QSettings& settings)
{
    IndicatorClientCommon::init(settings);

    qmlRegisterType<NetworkAgent>("NetworkSettings", 0, 1, "NetworkAgent");
    // setIcon(QUrl("image://gicon/wifi-none"));
}

QUrl IndicatorClientNetwork::iconComponentSource() const
{
    return QUrl("qrc:/indicatorsclient/qml/NetworkIndicatorIcon.qml");
}

QUrl IndicatorClientNetwork::pageComponentSource() const
{
    return QUrl("qrc:/indicatorsclient/qml/NetworkIndicatorPage.qml");
}
