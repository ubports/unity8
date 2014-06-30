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

CachingNetworkManagerFactory::CachingNetworkManagerFactory()
    : m_cache(new QNetworkDiskCache())
{
    m_cache->setCacheDirectory(QString("%1/network").arg(QStandardPaths::writableLocation(QStandardPaths::CacheLocation)));
}

QNetworkAccessManager *CachingNetworkManagerFactory::create(QObject *parent) {
    QNetworkAccessManager *manager = new QNetworkAccessManager(parent);
    manager->setCache(m_cache);
    return manager;
}
