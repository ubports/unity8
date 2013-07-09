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

CombinedFilterOptions::CombinedFilterOptions(const std::vector<unity::dash::FilterOption::Ptr>& list, QObject *parent)
    : QAbstractListModel(parent)
{
    initList(list);
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

void CombinedFilterOptions::initList(const std::vector<unity::dash::FilterOption::Ptr>& list)
{
    // combine options, e.g. A, B, C becomes A-B, B-C, C
    unsigned int i = 0;
    while (i < list.size() - 1) {
        unity::dash::FilterOption::Ptr option1 = list[i];
        unity::dash::FilterOption::Ptr option2 = list[i+1];
        auto co = new CombinedFilterOption(option1, option2, this);
        connect(co, SIGNAL(activeChanged(bool)), this, SLOT(onActiveChanged(bool)));
        addOption(co);
        ++i;
    }
    if (list.size() > 0) {
        auto co = new CombinedFilterOption(list[i], NULL, this);
        addOption(co);
    }
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
    // if option became active, need to disable all other options
    if (state) {
        CombinedFilterOption *option = dynamic_cast<CombinedFilterOption*>(QObject::sender());
        if (option) {
            Q_FOREACH (auto fo, m_list) {
                if (option != fo) {
                    // note that changing state will result in onActiveChanged signal for that option, but
                    // since it will be 'false', we won't end up in an infinite loop
                    fo->setInactive(*option);
                }
            }
        }
    }
}
