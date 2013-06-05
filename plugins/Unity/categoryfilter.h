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

#ifndef CATEGORY_FILTER_H
#define CATEGORY_FILTER_H

// Utils
#include "plugins/Utils/qsortfilterproxymodelqml.h"

class CategoryFilter : public QSortFilterProxyModelQML
{
    Q_OBJECT

    Q_PROPERTY(int index READ index WRITE setIndex NOTIFY indexChanged)

public:
    explicit CategoryFilter(QObject* parent = 0);

    /* getters */
    int index() const;

    /* setters */
    void setIndex(int index);

Q_SIGNALS:
    void indexChanged(int index);

private:
    int m_index;
};

#endif // CATEGORY_FILTER_H
