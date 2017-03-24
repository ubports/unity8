/* Copyright (C) 2013, 2015 Canonical, Ltd.
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

#include "quicklistentry.h"

QuickListEntry::QuickListEntry()
    : m_hasSeparator(false)
    , m_isPrivate(false)
{
}

QString QuickListEntry::actionId() const
{
    return m_actionId;
}

void QuickListEntry::setActionId(const QString &actionId)
{
    m_actionId = actionId;
}

QString QuickListEntry::text() const
{
    return m_text;
}

void QuickListEntry::setText(const QString &text)
{
    m_text = text;
}

QString QuickListEntry::icon() const
{
    return m_icon;
}

void QuickListEntry::setIcon(const QString &icon)
{
    m_icon = icon;
}

bool QuickListEntry::clickable() const
{
    return !m_actionId.isEmpty();
}

void QuickListEntry::setHasSeparator(bool hasSeparator)
{
    m_hasSeparator = hasSeparator;
}

bool QuickListEntry::hasSeparator() const
{
    return m_hasSeparator;
}

bool QuickListEntry::operator==(const QuickListEntry &other)
{
    return !other.actionId().isEmpty() && other.actionId() == m_actionId;
}

bool QuickListEntry::isPrivate() const
{
    return m_isPrivate;
}

void QuickListEntry::setIsPrivate(bool isPrivate)
{
    m_isPrivate = isPrivate;
}
