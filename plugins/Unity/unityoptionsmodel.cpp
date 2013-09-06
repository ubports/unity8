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
#include "unityoptionsmodel.h"

// local
#include "filteroption.h"

UnityOptionsModel::UnityOptionsModel(QObject *parent,
                                     const std::vector<unity::dash::FilterOption::Ptr> options,
                                     sigc::signal<void, unity::dash::FilterOption::Ptr> optionAdded,
                                     sigc::signal<void, unity::dash::FilterOption::Ptr> optionRemoved,
                                     bool showAllOption) :
    GenericOptionsModel(showAllOption, parent)
{
    setOptions(options, optionAdded, optionRemoved);
}

void UnityOptionsModel::setOptions(const std::vector<unity::dash::FilterOption::Ptr> options,
                                            sigc::signal<void, unity::dash::FilterOption::Ptr> optionAdded,
                                            sigc::signal<void, unity::dash::FilterOption::Ptr> optionRemoved)
{
    for (unsigned int i=0; i<options.size(); i++)
    {
        addOption(new FilterOption(options[i], this));
    }
    optionAdded.connect(sigc::mem_fun(this, &UnityOptionsModel::onOptionAdded));
    optionRemoved.connect(sigc::mem_fun(this, &UnityOptionsModel::onOptionRemoved));
}

void UnityOptionsModel::onOptionAdded(unity::dash::FilterOption::Ptr option)
{
    int index = m_options.count();
    if (index >= 0)
    {
        beginInsertRows(QModelIndex(), index, index);
        addOption(new FilterOption(option, this));
        endInsertRows();
    }
}

void UnityOptionsModel::onOptionRemoved(unity::dash::FilterOption::Ptr option)
{
    auto index = indexOf(QString::fromStdString(option->id));
    if (index >= 0)
    {
        beginRemoveRows(QModelIndex(), index, index);
        removeOption(index);
        endRemoveRows();
    }
}
