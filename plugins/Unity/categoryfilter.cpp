/*
 * Copyright (C) 2013 Canonical, Ltd.
 *
 * Authors:
 *  Michał Sawicz <michal.sawicz@canonical.com>
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

#include "categoryfilter.h"

int const CATEGORY_COLUMN = 2;

CategoryFilter::CategoryFilter(QObject* parent)
    : QSortFilterProxyModelQML(parent)
    , m_index(-1)
{
    setDynamicSortFilter(true);
    setFilterRole(CATEGORY_COLUMN);
    setFilterRegExp(QString("^%1$").arg(m_index));
}

int CategoryFilter::index() const
{
    return m_index;
}

void CategoryFilter::setIndex(int index)
{
    if (index != m_index) {
        m_index = index;
        setFilterRegExp(QString("^%1$").arg(m_index));
        Q_EMIT indexChanged(m_index);
    }
}
