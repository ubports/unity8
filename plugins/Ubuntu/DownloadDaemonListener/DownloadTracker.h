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


#ifndef DOWNLOADTRACKER_H
#define DOWNLOADTRACKER_H

#include <interface/downloadtrackeradaptor.h>

#include <QObject>
#include <QDBusObjectPath>

class DownloadTracker : public QObject
{
    Q_OBJECT
    Q_DISABLE_COPY(DownloadTracker)
    Q_PROPERTY(QString service READ service WRITE setService NOTIFY serviceChanged)
    Q_PROPERTY(QString dbusPath READ dbusPath WRITE setDbusPath NOTIFY dbusPathChanged)
    Q_PROPERTY(bool serviceReady READ isServiceReady NOTIFY serviceReadyChanged)

public:
    explicit DownloadTracker(QObject *parent = 0);

    QString service() const;
    QString dbusPath() const;
    bool isServiceReady() const;

    void setDbusPath(const QString& path);
    void setService(const QString& service);

Q_SIGNALS:
    void serviceChanged(const QString &service);
    void dbusPathChanged(const QString &dbusPath);
    void serviceReadyChanged(const bool serviceReady);

    void canceled(bool success);
    void error(const QString &error);
    void finished(const QString &path);
    void paused(bool success);
    void progress(qulonglong received, qulonglong total);
    void resumed(bool success);
    void started(bool success);

private:
    QString m_dbusPath;
    QString m_service;
    DownloadTrackerAdaptor* m_adaptor;

    void startService();
};

#endif // DOWNLOADTRACKER_H
