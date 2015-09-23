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
#include "MockQuickListModel.h"

#include <paths.h>

using namespace unity::shell::launcher;

MockLauncherItem::MockLauncherItem(const QString &appId, const QString& desktopFile, const QString& name, const QString& icon, QObject* parent):
    LauncherItemInterface(parent),
    m_appId(appId),
    m_desktopFile(desktopFile),
    m_name(name),
    m_icon(qmlDirectory() + "/graphics/applicationIcons/" + icon + ".png"),
    m_pinned(false),
    m_running(false),
    m_recent(false),
    m_progress(-1),
    m_count(0),
    m_countVisible(false),
    m_focused(false),
    m_alerting(false),
    m_quickList(new MockQuickListModel(this))
{
}

MockLauncherItem::~MockLauncherItem()
{
}

QString MockLauncherItem::appId() const
{
    return m_appId;
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

bool MockLauncherItem::pinned() const
{
    return m_pinned;
}

void MockLauncherItem::setPinned(bool pinned)
{
    if (m_pinned != pinned)
    {
        m_pinned = pinned;
        Q_EMIT pinnedChanged(m_pinned);
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
        if (m_countVisible) {
            setAlerting(true);
        }
    }
}

bool MockLauncherItem::countVisible() const
{
    return m_countVisible;
}

void MockLauncherItem::setCountVisible(bool countVisible)
{
    if (m_countVisible != countVisible) {
        m_countVisible = countVisible;
        Q_EMIT countVisibleChanged(countVisible);
        if (countVisible) {
            setAlerting(true);
        }
    }
}

bool MockLauncherItem::focused() const
{
    return m_focused;
}

void MockLauncherItem::setFocused(bool focused)
{
    if (m_focused != focused)
    {
        m_focused = focused;
        Q_EMIT focusedChanged(focused);
    }
}

bool MockLauncherItem::alerting() const
{
    return m_alerting;
}

void MockLauncherItem::setAlerting(bool alerting)
{
    if (m_alerting != alerting) {
        m_alerting = alerting;
        Q_EMIT alertingChanged(alerting);
    }
}

unity::shell::launcher::QuickListModelInterface *MockLauncherItem::quickList() const
{
    return m_quickList;
}
