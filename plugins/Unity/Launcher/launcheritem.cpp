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

#include "launcheritem.h"

LauncherItem::LauncherItem(const QString &appId, const QString &desktopFile, const QString &name, const QString &icon, QObject *parent) :
    LauncherItemInterface(parent),
    m_appId(appId),
    m_desktopFile(desktopFile),
    m_name(name),
    m_icon(icon),
    m_favorite(false),
    m_running(false),
    m_recent(false),
    m_progress(-1),
    m_count(0)
{

}

QString LauncherItem::appId()
{
    return m_appId;
}

QString LauncherItem::desktopFile() const
{
    return m_desktopFile;
}

QString LauncherItem::name() const
{
    return m_name;
}

QString LauncherItem::icon() const
{
    return m_icon;
}

bool LauncherItem::favorite() const
{
    return m_favorite;
}

void LauncherItem::setFavorite(bool favorite)
{
    if (m_favorite != favorite) {
        m_favorite = favorite;
        Q_EMIT favoriteChanged(favorite);
    }
}

bool LauncherItem::running() const
{
    return m_running;
}

void LauncherItem::setRunning(bool running)
{
    if (m_running != running) {
        m_running = running;
        Q_EMIT runningChanged(running);
    }
}

bool LauncherItem::recent() const
{
    return m_recent;
}

void LauncherItem::setRecent(bool recent)
{
    if (m_recent != recent) {
        m_recent = recent;
        Q_EMIT recentChanged(recent);
    }
}

int LauncherItem::progress() const
{
    return m_progress;
}

void LauncherItem::setProgress(int progress)
{
    if (m_progress != progress) {
        m_progress = progress;
        Q_EMIT progressChanged(progress);
    }
}

int LauncherItem::count() const
{
    return m_count;
}

void LauncherItem::setCount(int count)
{
    if (m_count != count) {
        m_count = count;
        Q_EMIT countChanged(count);
    }
}
