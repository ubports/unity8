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

#ifndef QUICKLISTENTRY_H
#define QUICKLISTENTRY_H

#include <QString>

class QuickListEntry
{
public:
    QuickListEntry();

    QString actionId() const;
    void setActionId(const QString &actionId);

    QString text() const;
    void setText(const QString &text);

    QString icon() const;
    void setIcon(const QString &icon);

    bool clickable() const;

    void setHasSeparator(bool hasSeparator);
    bool hasSeparator() const;

    bool operator==(const QuickListEntry & other);

    bool isPrivate() const;
    void setIsPrivate(bool isPrivate);

private:
    QString m_actionId;
    QString m_text;
    QString m_icon;
    bool m_hasSeparator;
    bool m_isPrivate;
};

#endif // QUICKLISTENTRY
