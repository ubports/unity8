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
#include "showallfilteroption.h"

#include <libintl.h>

unsigned int ShowAllFilterOption::m_showAllCount = 0;

ShowAllFilterOption::ShowAllFilterOption(QObject *parent) :
    AbstractFilterOption(parent),
    m_active(false)
{
    m_id = QString("show_all::%1").arg(m_showAllCount++);
}

QString ShowAllFilterOption::id() const
{
    return m_id;
}

QString ShowAllFilterOption::name() const
{
    return QString::fromUtf8(dgettext("unity", "All"));
}

QString ShowAllFilterOption::iconHint() const
{
    return QString::Null();
}

bool ShowAllFilterOption::active() const
{
    return m_active;
}

void ShowAllFilterOption::setActive(bool active)
{
    if (active != m_active) {
        m_active = active;
        Q_EMIT activeChanged(m_active);
    }
}
