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

#ifndef MOCK_PAYMENTS_H
#define MOCK_PAYMENTS_H

#include <QObject>


class MockPayments : public QObject
{
    Q_OBJECT
    Q_DISABLE_COPY(MockPayments)
    Q_PROPERTY(QString currency READ currency WRITE setCurrency NOTIFY currencyChanged)
    Q_PROPERTY(double price READ price WRITE setPrice NOTIFY priceChanged)
    Q_PROPERTY(QString storeItemId READ storeItemId WRITE setStoreItemId NOTIFY storeItemIdChanged)
    Q_PROPERTY(QString formattedPrice READ formattedPrice NOTIFY formattedPriceChanged)

public:
    explicit MockPayments(QObject *parent = 0);

    QString currency() const;
    double price() const;
    QString storeItemId() const;
    QString formattedPrice() const;

    void setCurrency(const QString& currency);
    void setPrice(const double price);
    void setStoreItemId(const QString& store_item_id);
    Q_INVOKABLE void start();

Q_SIGNALS:
    void currencyChanged(const QString& currency);
    void priceChanged(const double price);
    void storeItemIdChanged(const QString &store_item_id);
    void formattedPriceChanged(const QString &formatted_price);

    void purchaseError(const QString &error);
    void purchaseCompleted();

private:
    QString m_currency;
    double m_price;
    QString m_store_item_id;
};

#endif // PAYMENTS_H
