/*
 * Copyright (C) 2013 Canonical, Ltd.
 *
 * Authors:
 *  Michael Zanetti <michael.zanetti@canonical.com>
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

#ifndef LAUNCHERITEM_H
#define LAUNCHERITEM_H

#include <unity/shell/launcher/LauncherItemInterface.h>

using namespace unity::shell::launcher;

class LauncherItem: public LauncherItemInterface
{
    Q_OBJECT
public:
    LauncherItem(const QString &appId, const QString &desktopFile, const QString &name, const QString &icon, QObject *parent = 0);

    QString appId();

    QString desktopFile() const;

    QString name() const;
    QString icon() const;

    bool favorite() const;
    void setFavorite(bool favorite);

    bool running() const;
    void setRunning(bool running);

    bool recent() const;
    void setRecent(bool recent);

    int progress() const;
    void setProgress(int progress);

    int count() const;
    void setCount(int count);

Q_SIGNALS:
    void favoriteChanged(bool favorite);
    void runningChanged(bool running);

private:
    QString m_appId;
    QString m_desktopFile;
    QString m_name;
    QString m_icon;
    bool m_favorite;
    bool m_running;
    bool m_recent;
    int m_progress;
    int m_count;
};

#endif // LAUNCHERITEM_H
