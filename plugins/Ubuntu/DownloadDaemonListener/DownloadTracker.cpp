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

        connect(m_adaptor, SIGNAL(canceled(bool)), this, SIGNAL(canceled(bool)));
        connect(m_adaptor, SIGNAL(error(const QString &)), this, SIGNAL(error(const QString &)));
        connect(m_adaptor, SIGNAL(finished(const QString &)), this, SIGNAL(finished(const QString &)));
        connect(m_adaptor, SIGNAL(paused(bool)), this, SIGNAL(paused(bool)));
        connect(m_adaptor, SIGNAL(progress(qulonglong, qulonglong)), this, SIGNAL(progress(qulonglong, qulonglong)));
        connect(m_adaptor, SIGNAL(resumed(bool)), this, SIGNAL(resumed(bool)));
        connect(m_adaptor, SIGNAL(started(bool)), this, SIGNAL(started(bool)));
    }
    // FIXME find a better way of determining if the service is ready
    Q_EMIT serviceReadyChanged(m_adaptor && m_adaptor->isValid());
}
