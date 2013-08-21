/*
 * Copyright (C) 2013 Canonical, Ltd.
 *
 * Authors:
 *  Pawel Stolowski <pawel.stolowski@canonical.com>
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

// self
#include "ratingfilteroption.h"

RatingFilterOption::RatingFilterOption(const QString &id, float value, QObject *parent) :
    AbstractFilterOption(parent),
    m_active(false),
    m_id(id),
    m_value(value)
{
}

QString RatingFilterOption::id() const
{
    return m_id;
}

QString RatingFilterOption::name() const
{
    return QString::Null();
}

QString RatingFilterOption::iconHint() const
{
    return QString::Null();
}

float RatingFilterOption::value() const
{
    return m_value;
}

bool RatingFilterOption::active() const
{
    return m_active;
}

void RatingFilterOption::setActive(bool active)
{
    if (active != m_active) {
        m_active = active;
        Q_EMIT activeChanged(m_active);
    }
}
