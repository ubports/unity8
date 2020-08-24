/*
 * Copyright (C) 2019 UBports Foundation
 * Author(s): Marius Gripsgard <marius@ubports.com>
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

#include <QFileSystemWatcher>
#include <QHash>
#include <QFileInfo>

class QFileInfo;

class XdgWatcher: public QObject
{
    Q_OBJECT
public:
    XdgWatcher(QObject* parent = nullptr);

Q_SIGNALS:
    void appAdded(const QString &appId);
    void appRemoved(const QString &appId);
    void appInfoChanged(const QString &appId);

private Q_SLOTS:
    void onDirectoryChanged(const QString &path);
    void onFileChanged(const QString &path);

private:
    const QString toStandardAppId(const QFileInfo fileInfo) const;
    const QString getAppId(const QFileInfo file) const;
    const QString stripAppIdVersion(const QString rawAppID) const;

    QFileSystemWatcher* m_watcher;
    QHash<const QString, QString> m_registry;
};
