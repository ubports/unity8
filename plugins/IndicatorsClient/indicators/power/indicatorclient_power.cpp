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
 *      Ubo Riboni <ugo.riboni@canonical.com>
 */

#include "indicatorclient_power.h"

IndicatorClientPower::IndicatorClientPower(QObject *parent)
    : IndicatorClientCommon(parent)
{
    setTitle("Battery");
    setPriority(IndicatorPriority::POWER);
}

void IndicatorClientPower::init(const QSettings& settings)
{
    IndicatorClientCommon::init(settings);
    Q_INIT_RESOURCE(indicatorclient_power);
}