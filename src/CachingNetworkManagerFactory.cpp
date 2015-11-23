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

#include "CachingNetworkManagerFactory.h"

#include <QNetworkDiskCache>
#include <QNetworkAccessManager>
#include <QStandardPaths>

CachingNetworkAccessManager::CachingNetworkAccessManager(QObject *parent)
    : QNetworkAccessManager(parent)
{
    m_networkingStatus = new ubuntu::connectivity::NetworkingStatus(this);
}

QNetworkReply* CachingNetworkAccessManager::createRequest(Operation op, const QNetworkRequest &request, QIODevice *outgoingData)
{
    if (m_networkingStatus->status() != ubuntu::connectivity::NetworkingStatus::Status::Online) {
        qDebug() << "Not connected to the internet. Request for" << request.url().toString() << "will be served only from the cache.";
        QNetworkRequest req(request);
        req.setAttribute(QNetworkRequest::CacheLoadControlAttribute, QNetworkRequest::AlwaysCache);
        return QNetworkAccessManager::createRequest(op, req, outgoingData);
    }

    return QNetworkAccessManager::createRequest(op, request, outgoingData);
}

CachingNetworkManagerFactory::CachingNetworkManagerFactory()
{
}

QNetworkAccessManager *CachingNetworkManagerFactory::create(QObject *parent) {
    QNetworkAccessManager *manager = new CachingNetworkAccessManager(parent);

    QNetworkDiskCache* cache = new QNetworkDiskCache(manager);
    cache->setCacheDirectory(QStringLiteral("%1/network").arg(QStandardPaths::writableLocation(QStandardPaths::CacheLocation)));

    manager->setCache(cache);
    return manager;
}
