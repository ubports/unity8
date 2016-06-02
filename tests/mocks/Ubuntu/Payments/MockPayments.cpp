/*
 * Copyright (C) 2014 Canonical, Ltd.
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

#include "MockPayments.h"

#include <QLocale>


MockPayments::MockPayments(QObject *parent)
    : QObject(parent)
    , m_price(0)
{
}

QString MockPayments::currency() const
{
    return m_currency;
}

double MockPayments::price() const
{
    return m_price;
}

QString MockPayments::storeItemId() const
{
    return m_store_item_id;
}

QString MockPayments::formattedPrice() const
{
    QLocale locale;
    return locale.toCurrencyString(m_price, m_currency);
}

void MockPayments::setCurrency(const QString &currency)
{
    if(m_currency != currency) {
        m_currency = currency;
        Q_EMIT currencyChanged(currency);
        Q_EMIT formattedPriceChanged(formattedPrice());
    }
}

void MockPayments::setPrice(const double price)
{
    if(m_price != price) {
        m_price = price;
        Q_EMIT priceChanged(price);
        Q_EMIT formattedPriceChanged(formattedPrice());
    }
}

void MockPayments::setStoreItemId(const QString &store_item_id)
{
    if (m_store_item_id != store_item_id) {
        m_store_item_id = store_item_id;
        Q_EMIT storeItemIdChanged(m_store_item_id);
    }

    if (m_store_item_id.isEmpty()) {
        return;
    }
}

void MockPayments::start()
{
    if (m_store_item_id.isEmpty()) {
        Q_EMIT purchaseError("No item ID supplied.");
    }
}

void MockPayments::process()
{
    if (m_store_item_id == "com.example.cancel") {
        Q_EMIT purchaseCancelled();
    } else if (m_store_item_id == "com.example.invalid") {
        Q_EMIT purchaseError("Purchase failed.");
    } else {
        Q_EMIT purchaseCompleted();
    }
}
