/*
 * Copyright (C) 2011, 2013 Canonical, Ltd.
 *
 * Authors:
 *  Florian Boucault <florian.boucault@canonical.com>
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

#ifndef FILTEROPTION_H
#define FILTEROPTION_H

// Local
#include "abstractfilteroption.h"
#include "listmodelwrapper.h"
#include "signalslist.h"

// libunity-core
#include <UnityCore/Filter.h>

class Q_DECL_EXPORT FilterOption : public AbstractFilterOption
{
    Q_OBJECT

public:
    explicit FilterOption(unity::dash::FilterOption::Ptr unityFilterOption, QObject *parent = nullptr);

    /* getters */
    QString id() const override;
    QString name() const override;
    QString iconHint() const override;
    bool active() const override;

    /* setters */
    void setActive(bool active) override;

private:
    void setUnityFilterOption(unity::dash::FilterOption::Ptr unityFilterOption);
    SignalsList m_signals;

    unity::dash::FilterOption::Ptr m_unityFilterOption;
};

Q_DECLARE_METATYPE(FilterOption*)

typedef ListModelWrapper<FilterOption, unity::dash::FilterOption::Ptr> FilterOptions;
Q_DECLARE_METATYPE(FilterOptions*)

#endif // FILTEROPTION_H
