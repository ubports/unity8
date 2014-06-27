/*
 * Copyright (C) 2014 Canonical Ltd.
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
 */

#include <QLocale>

#include <libpay/pay-package.h>

#include "Payments.h"


// The observer callback for the package we are watching.
static void observer(PayPackage* /* package */, const char* itemid, PayPackageItemStatus status, void* user_data) {
    // This function is called in libpay's thread, so be careful what you call
    // Emitting signals should be fine as long as they use Queued or Auto
    // connections (the default)
    // http://qt-project.org/doc/qt-5/threads-qobject.html#signals-and-slots-across-threads

    Payments *self = static_cast<Payments*>(user_data);

    // If the item ID is different, ignore it.
    if (itemid != self->storeItemId()) {
        return;
    }

    // FIXME: No error reporting from libpay, but we need to show some
    // types of errors to the user. https://launchpad.net/bugs/1333403
    switch (status) {
    case PAY_PACKAGE_ITEM_STATUS_PURCHASED:
        Q_EMIT self->purchaseCompleted();
        break;
    default:
        break;
    }
}

Payments::Payments(QObject *parent)
    : QObject(parent)
{
    m_package = pay_package_new("click-scope");
    pay_package_item_observer_install(m_package, observer, this);
}

Payments::~Payments()
{
    pay_package_item_observer_uninstall(m_package, observer, this);
    pay_package_delete(m_package);
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
    if(m_currency != currency) {
        m_currency = currency;
        Q_EMIT currencyChanged(currency);
        Q_EMIT formattedPriceChanged(formattedPrice());
    }
}

void Payments::setPrice(const double price)
{
    if(m_price != price) {
        m_price = price;
        Q_EMIT priceChanged(price);
        Q_EMIT formattedPriceChanged(formattedPrice());
    }
}

void Payments::setStoreItemId(const QString &store_item_id)
{
    if (m_store_item_id != store_item_id) {
        m_store_item_id = store_item_id;
        Q_EMIT storeItemIdChanged(m_store_item_id);
    }

    if (m_store_item_id.isEmpty()) {
        return;
    }

    pay_package_item_start_verification(m_package, m_store_item_id.toLocal8Bit().data());
}

void Payments::start()
{
    pay_package_item_start_purchase(m_package, m_store_item_id.toLocal8Bit().data());
}
