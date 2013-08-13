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

#ifndef CHECKOPTIONFILTER_H
#define CHECKOPTIONFILTER_H

// Qt
#include <QObject>
#include <QMetaType>

// libunity-core
#include <UnityCore/CheckOptionFilter.h>

// Local
#include "filter.h"
#include "signalslist.h"

class Q_DECL_EXPORT CheckOptionFilter : public Filter
{
    Q_OBJECT

public:
    explicit CheckOptionFilter(QObject *parent = nullptr);

    /* getters */
    GenericOptionsModel* options() const override;

protected:
    void setUnityFilter(unity::dash::Filter::Ptr filter) override;

private:
    void onOptionsChanged(unity::dash::CheckOptionFilter::CheckOptions filter);

    unity::dash::CheckOptionFilter::Ptr m_unityCheckOptionFilter;
    SignalsList m_signals;
    GenericOptionsModel* m_options;
};

Q_DECLARE_METATYPE(CheckOptionFilter*)

#endif // CHECKOPTIONFILTER_H
