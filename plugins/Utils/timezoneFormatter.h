/*
 * Copyright 2015 Canonical Ltd.
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

#ifndef TIMEZONE_FORMATTER_H
#define TIMEZONE_FORMATTER_H

#include <QObject>

class TimezoneFormatter : public QObject
{
    Q_OBJECT
public:
    TimezoneFormatter(QObject * parent = nullptr);
    ~TimezoneFormatter() = default;

    Q_INVOKABLE QString currentTimeInTimezone(const QVariant &tzId) const;
    Q_INVOKABLE QString currentTimeInTimezoneWithAbbrev(const QVariant &tzId) const;
};

#endif
