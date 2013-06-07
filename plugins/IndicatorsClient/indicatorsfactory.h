/*
 * Copyright (C) 2012 Canonical, Ltd.
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
 *
 * Author: Nick Dedekind <nick.dedekind@canonical.com>
 */

#ifndef INDICATORS_FACTORY_H
#define INDICATORS_FACTORY_H

#include <QString>
#include <QObject>
#include <QHash>

#include "indicatorclientinterface.h"

class IndicatorFactoryItem
{
public:
    virtual ~IndicatorFactoryItem() {}
    virtual IndicatorClientInterface::Ptr create(QObject* parent = 0) = 0;
};

template<class TYPE>
class IndicatorFactoryItemTyped : public IndicatorFactoryItem
{
public:
    IndicatorFactoryItemTyped() {}

    IndicatorClientInterface::Ptr create(QObject* parent = 0) { return std::make_shared<TYPE>(parent); }
};

class IndicatorsFactory : public QObject
{
    Q_OBJECT
public:
    virtual ~IndicatorsFactory();

    IndicatorClientInterface::Ptr create(const QString& indicator, QObject* parent = 0);

    template<class TYPE>
    void registerIndicator(const QString& indicator)
    {
        if (m_factoryItems.contains(indicator))
            return;
        m_factoryItems[indicator] = new IndicatorFactoryItemTyped<TYPE>();
        Q_EMIT registered(indicator);
    }

    bool isRegistered(const QString& indicator);

    static IndicatorsFactory& instance();

Q_SIGNALS:
    void registered(const QString& indicator);

private:
    IndicatorsFactory();

    QHash<QString, IndicatorFactoryItem*> m_factoryItems;
};

#endif // INDICATORSCLIENT_PLUGIN_H
