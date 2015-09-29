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

#include <QTimeZone>

#include "timezoneFormatter.h"

TimezoneFormatter::TimezoneFormatter(QObject *parent)
    : QObject(parent)
{
}

QString TimezoneFormatter::currentTimeInTimezone(const QVariant &tzId) const
{
    QTimeZone tz(tzId.toByteArray());
    if (tz.isValid()) {
        const QDateTime now = QDateTime::currentDateTime().toTimeZone(tz);
        // return locale-aware string in the form "day, hh:mm", e.g. "Mon 14:30" or "Mon 1:30 pm"
        return QStringLiteral("%1 %2").arg(now.toString("ddd")).arg(now.time().toString(Qt::DefaultLocaleShortDate));
    }
    return QString();
}
