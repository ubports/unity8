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

#ifndef UNITYOPTIONSMODEL_H
#define UNITYOPTIONSMODEL_H

#include "genericoptionsmodel.h"

// libunity-core
#include <UnityCore/Filter.h>

#include <sigc++/signal.h>

class UnityOptionsModel : public GenericOptionsModel
{
    Q_OBJECT

public:
    UnityOptionsModel(QObject *parent,
                      const std::vector<unity::dash::FilterOption::Ptr> options,
                      sigc::signal<void, unity::dash::FilterOption::Ptr> optionAdded,
                      sigc::signal<void, unity::dash::FilterOption::Ptr> optionRemoved);

private:
    void setOptions(const std::vector<unity::dash::FilterOption::Ptr> options,
                          sigc::signal<void, unity::dash::FilterOption::Ptr> optionAdded,
                          sigc::signal<void, unity::dash::FilterOption::Ptr> optionRemoved);

    void onOptionAdded(unity::dash::FilterOption::Ptr option);
    void onOptionRemoved(unity::dash::FilterOption::Ptr option);
};

#endif // UNITYOPTIONSMODEL_H
