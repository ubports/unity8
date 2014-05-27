/*
 * Copyright (C) 2013 - Canonical Ltd.
 *
 * This program is free software: you can redistribute it and/or modify it
 * under the terms of the GNU Lesser General Public License, as
 * published by the  Free Software Foundation; either version 2.1 or 3.0
 * of the License.
 *
 * This program is distributed in the hope that it will be useful, but
 * WITHOUT ANY WARRANTY; without even the implied warranties of
 * MERCHANTABILITY, SATISFACTORY QUALITY or FITNESS FOR A PARTICULAR
 * PURPOSE.  See the applicable version of the GNU Lesser General Public
 * License for more details.
 *
 * You should have received a copy of both the GNU Lesser General Public
 * License along with this program. If not, see <http://www.gnu.org/licenses/>
 *
 * Authored by: Diego Sarmentero <diego.sarmentero@canonical.com>
 */

#include <QLocale>
#include <QTimer>

#include "Payments.h"

Payments::Payments(QObject *parent)
    : QObject(parent)
{
}

QString Payments::currency() const
{
    return m_currency;
}

double Payments::price() const
{
    return m_price;
}

QString Payments::storeItemId() const
{
    return m_store_item_id;
}

QString Payments::formattedPrice() const
{
    QLocale locale;
    return locale.toCurrencyString(m_price, m_currency);
}

void Payments::setCurrency(const QString &currency)
{
    if(m_currency != currency){
        m_currency = currency;
        Q_EMIT currencyChanged(currency);
        Q_EMIT formattedPriceChanged(formattedPrice());
    }
}

void Payments::setPrice(const double price)
{
    if(m_price != price){
        m_price = price;
        Q_EMIT priceChanged(price);
        Q_EMIT formattedPriceChanged(formattedPrice());
    }
}

void Payments::setStoreItemId(const QString &store_item_id)
{
    if(m_store_item_id != store_item_id){
        m_store_item_id = store_item_id;
        Q_EMIT storeItemIdChanged(store_item_id);
    }
}

void Payments::start()
{
    qDebug("starting the purchase");
    // start the purchase here, raise finished(), error or canceled when done
    QTimer::singleShot(3000, this, SIGNAL(finished()));
    // FIXME ^^^^
}
