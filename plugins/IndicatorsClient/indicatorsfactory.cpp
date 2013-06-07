/*
 * Copyright (C) 2013 Canonical, Ltd.
 *
 * Authors:
 *  Michał Sawicz <michal.sawicz@canonical.com>
 *
 * This program is free software; you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation; version 3.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.
 */

// local
#include "indicatorsfactory.h"

// indicators
#include "indicators/datetime/indicatorclient_datetime.h"
#include "indicators/messaging/indicatorclient_messaging.h"
#include "indicators/network/indicatorclient_network.h"
#include "indicators/power/indicatorclient_power.h"
#include "indicators/sound/indicatorclient_sound.h"

IndicatorsFactory::IndicatorsFactory()
{
    registerItem<IndicatorClientDateTime>("indicator-datetime");
    registerItem<IndicatorClientMessaging>("indicator-messaging");
    registerItem<IndicatorClientNetwork>("indicator-network");
    registerItem<IndicatorClientPower>("indicator-power");
    registerItem<IndicatorClientSound>("indicator-sound");
}

IndicatorsFactory::~IndicatorsFactory()
{
    qDeleteAll(m_factoryItems);
}

template<class TYPE>
void IndicatorsFactory::registerItem(const QString& indicator)
{
    m_factoryItems[indicator] = new IndicatorFactoryItemTyped<TYPE>();
}

IndicatorClientInterface::Ptr IndicatorsFactory::create(const QString& indicator, QObject* parent)
{
    if (!m_factoryItems.contains(indicator))
        return IndicatorClientInterface::Ptr();
    return m_factoryItems[indicator]->create(parent);
}