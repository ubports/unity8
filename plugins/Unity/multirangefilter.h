/*
 * Copyright (C) 2011 Canonical, Ltd.
 *
 * Authors:
 *  Florian Boucault <florian.boucault@canonical.com>
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

#ifndef MULTIRANGEFILTER_H
#define MULTIRANGEFILTER_H

// Qt
#include <QObject>
#include <QMetaType>

// libunity-core
#include <UnityCore/MultiRangeFilter.h>

// Local
#include "filter.h"
#include "filteroption.h"

class MultiRangeFilter : public Filter
{
    Q_OBJECT

    Q_PROPERTY(FilterOptions* options READ options NOTIFY optionsChanged)

public:
    explicit MultiRangeFilter(QObject *parent = 0);

    /* getters */
    FilterOptions* options() const;

Q_SIGNALS:
    void optionsChanged();

protected:
    virtual void setUnityFilter(unity::dash::Filter::Ptr filter);

private:
    unity::dash::MultiRangeFilter::Ptr m_unityMultiRangeFilter;
    FilterOptions* m_options;

    void onOptionsChanged(unity::dash::MultiRangeFilter::Options);
};

Q_DECLARE_METATYPE(MultiRangeFilter*)

#endif // MULTIRANGEFILTER_H
