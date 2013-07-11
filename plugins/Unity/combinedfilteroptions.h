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

#ifndef COMBINEDOPTIONSWRAPPER_H
#define COMBINEDOPTIONSWRAPPER_H

// Qt
#include <QObject>

// libunity-core
#include <UnityCore/Filter.h>

// local
#include "genericlistmodel.h"

class CombinedFilterOptions : public GenericListModel
{
    Q_OBJECT

public:
    CombinedFilterOptions(const std::vector<unity::dash::FilterOption::Ptr>& list, QObject *parent = nullptr);

private Q_SLOTS:
    void onActiveChanged(bool state);

private:
    void initList(const std::vector<unity::dash::FilterOption::Ptr>& list);
};

Q_DECLARE_METATYPE(CombinedFilterOptions*)

#endif
