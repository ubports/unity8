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


#ifndef MYTYPE_H
#define MYTYPE_H

#include <QObject>
#include <QList>
#include <QDBusObjectPath>
#include <interface/downloadtrackeradaptor.h>

class DownloadTracker : public QObject
{
    Q_OBJECT
    Q_DISABLE_COPY(DownloadTracker)
    Q_PROPERTY(QString dbusPath WRITE setDbusPath)
    Q_PROPERTY(bool serviceReady READ isServiceReady)

public:
    explicit DownloadTracker(QObject *parent = 0);

    void setDbusPath(QString& path);
    bool isServiceReady();

Q_SIGNALS:
    void canceled(bool success);
    void error(const QString &error);
    void finished(const QString &path);
    void paused(bool success);
    void progress(qulonglong received, qulonglong total);
    void resumed(bool success);
    void started(bool success);

private:
    QString m_dbusPath;
    DownloadTrackerAdaptor* adaptor;
};

#endif // MYTYPE_H
