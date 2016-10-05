/*
 * Copyright (C) 2013-2016 Canonical Ltd.
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


#include "MockDownloadTracker.h"

MockDownloadTracker::MockDownloadTracker(QObject *parent)
    : QObject(parent)
    , m_active(false)
{
}

bool MockDownloadTracker::isServiceReady() const
{
    return m_active;
}

QString MockDownloadTracker::dbusPath() const
{
    return m_dbusPath;
}

void MockDownloadTracker::setDbusPath(const QString& path)
{
    if(m_dbusPath != path){
        m_dbusPath = path;
        startService();
    }
}

QString MockDownloadTracker::service() const
{
    return m_service;
}

void MockDownloadTracker::setService(const QString& service)
{
    if(m_service != service){
        m_service = service;
        startService();
    }
}

void MockDownloadTracker::startService()
{
    if(!m_service.isEmpty() && !m_dbusPath.isEmpty()) {
        m_active = true;
        Q_EMIT serviceReadyChanged(m_active);
        if(m_dbusPath == "finish") {
            Q_EMIT finished("downloadComplete");
        }else if(m_dbusPath == "error") {
            Q_EMIT error("DOWNLOAD ERROR");
        }else if(m_dbusPath == "processing") {
            Q_EMIT processing(m_dbusPath);
        }
    }
}
