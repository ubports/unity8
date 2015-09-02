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


#include "DownloadTracker.h"

DownloadTracker::DownloadTracker(QObject *parent)
    : QObject(parent)
    , m_adaptor(nullptr)
{
}

bool DownloadTracker::isServiceReady() const
{
    bool ready = false;
    if(m_adaptor != nullptr) {
        ready = m_adaptor->isValid();
    }

    return ready;
}

QString DownloadTracker::dbusPath() const
{
    return m_dbusPath;
}

void DownloadTracker::setDbusPath(const QString& path)
{
    if(m_dbusPath != path){
        m_dbusPath = path;
        startService();
        Q_EMIT dbusPathChanged(m_dbusPath);
    }
}

QString DownloadTracker::service() const
{
    return m_service;
}

void DownloadTracker::setService(const QString& service)
{
    if(m_service != service){
        m_service = service;
        startService();
        Q_EMIT serviceChanged(m_service);
    }
}

void DownloadTracker::startService()
{
    // FIXME update dbus path and service on changes
    if(!m_service.isEmpty() && !m_dbusPath.isEmpty()) {
        m_adaptor = new DownloadTrackerAdaptor(m_service, m_dbusPath, QDBusConnection::sessionBus(), this);

        connect(m_adaptor, &DownloadTrackerAdaptor::canceled, this, &DownloadTracker::canceled);
        connect(m_adaptor, &DownloadTrackerAdaptor::error, this, &DownloadTracker::error);
        connect(m_adaptor, &DownloadTrackerAdaptor::finished, this, &DownloadTracker::finished);
        connect(m_adaptor, &DownloadTrackerAdaptor::paused, this, &DownloadTracker::paused);
        connect(m_adaptor, static_cast<void (DownloadTrackerAdaptor::*)(qulonglong, qulonglong)>(&DownloadTrackerAdaptor::progress), this, &DownloadTracker::progress);
        connect(m_adaptor, &DownloadTrackerAdaptor::resumed, this, &DownloadTracker::resumed);
        connect(m_adaptor, &DownloadTrackerAdaptor::started, this, &DownloadTracker::started);
    }
    // FIXME find a better way of determining if the service is ready
    Q_EMIT serviceReadyChanged(m_adaptor && m_adaptor->isValid());
}
