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

#include "combinedfilteroptions.h"

CombinedFilterOptions::CombinedFilterOptions(const std::vector<unity::dash::FilterOption::Ptr>& list,
                                               sigc::signal<void, unity::dash::FilterOption::Ptr> itemAddedSignal,
                                               sigc::signal<void, unity::dash::FilterOption::Ptr> itemRemovedSignal, 
                                               QObject *parent)
    : QAbstractListModel(parent)
{
}


QVariant CombinedFilterOptions::data(const QModelIndex& index, int /* role */) const
{
    if (!index.isValid()) {
        return QVariant();
    }

    CombinedFilterOption* item = m_list.at(index.row());
    return QVariant::fromValue(item);
}

int CombinedFilterOptions::rowCount(const QModelIndex& /* parent */) const
{
    return m_list.count();
}

void CombinedFilterOptions::initList(const std::vector<unity::dash::FilterOption::Ptr>& list,
                                     sigc::signal<void, unity::dash::FilterOption::Ptr> itemAddedSignal,
                                     sigc::signal<void, unity::dash::FilterOption::Ptr> itemRemovedSignal)
{
    unsigned int i = 0;
    while (i < list.size()) {
        unity::dash::FilterOption::Ptr option1 = list[i];
        unity::dash::FilterOption::Ptr option2 = NULL;
        if (i < list.size()-1) {
            option2 = list[i+1];
        }
        auto co = new CombinedFilterOption(option1, option2);
        ++i;
    }
    if (list.size() > 1) {
        auto co = new CombinedFilterOption(list[i], NULL);
    }
        
    itemAddedSignal.connect(sigc::mem_fun(this, &CombinedFilterOptions::onItemAdded));
    itemRemovedSignal.connect(sigc::mem_fun(this, &CombinedFilterOptions::onItemRemoved));
}

void CombinedFilterOptions::onItemAdded(unity::dash::FilterOption::Ptr item)
{
}

void CombinedFilterOptions::onItemRemoved(unity::dash::FilterOption::Ptr item)
{
}
