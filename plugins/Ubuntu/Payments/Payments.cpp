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

#include <QDebug>
#include <QLocale>
#include <QTimer>

#include <libpay/pay-package.h>

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

void observer(PayPackage* package, const char* /*itemid*/, PayPackageItemStatus status, void* user_data) {
    // This function is called in libpay's thread, so be careful with what you call
    // Emitting signals should be fine as long as they use Queued or Auto connections (the default)
    // http://qt-project.org/doc/qt-5/threads-qobject.html#signals-and-slots-across-threads

    qDebug() << "observer called";
    Payments *self = static_cast<Payments*>(user_data);
    pay_package_item_observer_uninstall(package, observer, self);
    switch (status) {
    case PAY_PACKAGE_ITEM_STATUS_VERIFYING:
        break;
    case PAY_PACKAGE_ITEM_STATUS_PURCHASED:
        Q_EMIT self->finished();
        break;
    case PAY_PACKAGE_ITEM_STATUS_PURCHASING:
        break;
    case PAY_PACKAGE_ITEM_STATUS_NOT_PURCHASED:
        Q_EMIT self->error("not purchased");
        break;
    case PAY_PACKAGE_ITEM_STATUS_UNKNOWN:
        break;
    default:
        break;
    }

}

void Payments::start()
{
    qDebug("starting the purchase");

    auto ba = m_store_item_id.toLocal8Bit();
    qDebug() << "the item id is" << m_store_item_id;
    auto package = pay_package_new("clickscope");
    qDebug() << "after new" << ba.data();
    pay_package_item_observer_install(package, observer, this);
    qDebug() << "after observer install";
    //pay_package_item_start_verification(package, ba.data());
    qDebug() << "after start verify";
    pay_package_item_start_purchase(package, ba.data());
    qDebug() << "after start purchase";

    // FIXME: remove this when the payments service starts working ok
    finished();
}
