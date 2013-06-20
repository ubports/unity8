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
    // combine options, e.g. A, B, C becomes A-B, B-C, C
    unsigned int i = 0;
    while (i < list.size()) {
        unity::dash::FilterOption::Ptr option1 = list[i];
        unity::dash::FilterOption::Ptr option2 = NULL;
        if (i < list.size()-1) {
            option2 = list[i+1];
        }
        auto co = new CombinedFilterOption(option1);
        connect(co, SIGNAL(activeChanged(bool)), this, SLOT(onActiveChanged(bool)));
        addOption(co);
        ++i;
    }
    if (list.size() > 1) {
        auto co = new CombinedFilterOption(list[i-1], NULL);
        addOption(co);
    }
        
    itemAddedSignal.connect(sigc::mem_fun(this, &CombinedFilterOptions::onItemAdded));
    itemRemovedSignal.connect(sigc::mem_fun(this, &CombinedFilterOptions::onItemRemoved));
}

void CombinedFilterOptions::addOption(CombinedFilterOption *option)
{
    int index = m_list.count();
    beginInsertRows(QModelIndex(), index, index);
    m_list.insert(index, option);
    endInsertRows();
}

void CombinedFilterOptions::onActiveChanged(bool state)
{
    CombinedFilterOption *option = dynamic_cast<CombinedFilterOption*>(QObject::sender());
    if (option) {
        //TODO: de-activate all others?
    }
}

void CombinedFilterOptions::onItemAdded(unity::dash::FilterOption::Ptr item)
{
}

void CombinedFilterOptions::onItemRemoved(unity::dash::FilterOption::Ptr item)
{
}
