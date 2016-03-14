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
 *
 */

#ifndef CACHINGNETWORKMANAGERFACTORY_H
#define CACHINGNETWORKMANAGERFACTORY_H

#include <QQmlNetworkAccessManagerFactory>
#include <QNetworkAccessManager>

#include <connectivityqt/connectivity.h>

class CachingNetworkAccessManager : public QNetworkAccessManager
{
Q_OBJECT
public:
    CachingNetworkAccessManager(QObject *parent = 0);

protected:
    QNetworkReply* createRequest(Operation op, const QNetworkRequest &req, QIODevice *outgoingData = 0) override;

private:
    connectivityqt::Connectivity* m_networkingStatus;
};

class CachingNetworkManagerFactory : public QQmlNetworkAccessManagerFactory
{
public:
    CachingNetworkManagerFactory();

    QNetworkAccessManager *create(QObject *parent) override;
};

#endif // CACHINGNETWORKMANAGERFACTORY_H
