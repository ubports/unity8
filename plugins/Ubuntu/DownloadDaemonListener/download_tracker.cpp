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


#include "download_tracker.h"
#include <QDebug>

DownloadTracker::DownloadTracker(QObject *parent) :
    QObject(parent)
{
}

bool DownloadTracker::isServiceReady()
{
    bool ready = false;
    if(this->adaptor != nullptr) {
        ready = this->adaptor->isValid();
    }

    return ready;
}

QString DownloadTracker::dbusPath() const
{
    return m_dbusPath;
}

void DownloadTracker::setDbusPath(QString& path)
{
    if(path != "" && m_dbusPath != path){
        this->m_dbusPath = path;
        this->startService();
        Q_EMIT dbusPathChanged(this->m_dbusPath);
    }
}

QString DownloadTracker::service() const
{
    return m_service;
}

void DownloadTracker::setService(QString& service)
{
    if(service != "" && m_service != service){
        this->m_service = service;
        this->startService();
        Q_EMIT serviceChanged(this->m_service);
    }
}

void DownloadTracker::startService()
{
    if(!this->m_service.isEmpty() && !this->m_dbusPath.isEmpty()) {
        this->adaptor = new DownloadTrackerAdaptor(this->m_service, this->m_dbusPath, QDBusConnection::sessionBus(), 0);

        this->connect(this->adaptor, SIGNAL(canceled(bool)), this, SIGNAL(canceled(bool)));
        this->connect(this->adaptor, SIGNAL(error(const QString &)), this, SIGNAL(error(const QString &)));
        this->connect(this->adaptor, SIGNAL(finished(const QString &)), this, SIGNAL(finished(const QString &)));
        this->connect(this->adaptor, SIGNAL(paused(bool)), this, SIGNAL(paused(bool)));
        this->connect(this->adaptor, SIGNAL(progress(qulonglong, qulonglong)), this, SIGNAL(progress(qulonglong, qulonglong)));
        this->connect(this->adaptor, SIGNAL(resumed(bool)), this, SIGNAL(resumed(bool)));
        this->connect(this->adaptor, SIGNAL(started(bool)), this, SIGNAL(started(bool)));
    }
}
