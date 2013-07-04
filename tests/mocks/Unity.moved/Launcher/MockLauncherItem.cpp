/*
 * Copyright 2013 Canonical Ltd.
 *
 * This program is free software; you can redistribute it and/or modify
 * it under the terms of the GNU Lesser General Public License as published by
 * the Free Software Foundation; version 3.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU Lesser General Public License for more details.
 *
 * You should have received a copy of the GNU Lesser General Public License
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.
 *
 * Authors:
 *      Michael Zanetti <michael.zanetti@canonical.com>
 */

#include "MockLauncherItem.h"

using namespace unity::shell::launcher;

MockLauncherItem::MockLauncherItem(const QString& desktopFile, const QString& name, const QString& icon, QObject* parent):
    LauncherItemInterface(parent),
    m_desktopFile(desktopFile),
    m_name(name),
    m_icon(icon),
    m_favorite(false),
    m_running(false),
    m_recent(false),
    m_progress(8),
    m_count(8)
{

}

QString MockLauncherItem::desktopFile() const
{
    return m_desktopFile;
}

QString MockLauncherItem::name() const
{
    return m_name;
}

QString MockLauncherItem::icon() const
{
    return m_icon;
}

bool MockLauncherItem::favorite() const
{
    return m_favorite;
}

void MockLauncherItem::setFavorite(bool favorite)
{
    if (m_favorite != favorite)
    {
        m_favorite = favorite;
        Q_EMIT favoriteChanged(m_favorite);
    }
}

bool MockLauncherItem::running() const
{
    return m_running;
}

void MockLauncherItem::setRunning(bool running)
{
    if (m_running != running)
    {
        m_running = running;
        Q_EMIT runningChanged(running);
    }
}

bool MockLauncherItem::recent() const
{
    return m_recent;
}

void MockLauncherItem::setRecent(bool recent)
{
    if (m_recent != recent)
    {
        m_recent = recent;
        Q_EMIT recentChanged(recent);
    }
}

int MockLauncherItem::progress() const
{
    return m_progress;
}

void MockLauncherItem::setProgress(int progress)
{
    if (m_progress != progress)
    {
        m_progress = progress;
        Q_EMIT progressChanged(progress);
    }
}

int MockLauncherItem::count() const
{
    return m_count;
}

void MockLauncherItem::setCount(int count)
{
    if (m_count != count)
    {
        m_count = count;
        Q_EMIT countChanged(count);
    }
}
