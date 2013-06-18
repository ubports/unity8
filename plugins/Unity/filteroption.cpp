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

// Self
#include "filteroption.h"

// libunity-core
#include <UnityCore/Filter.h>

FilterOption::FilterOption(unity::dash::FilterOption::Ptr unityFilterOption, QObject *parent) :
    QObject(parent), m_unityFilterOption(NULL)
{
    setUnityFilterOption(unityFilterOption);
}

QString FilterOption::id() const
{
    return QString::fromStdString(m_unityFilterOption->id());
}

QString FilterOption::name() const
{
    return QString::fromStdString(m_unityFilterOption->name());
}

QString FilterOption::iconHint() const
{
    return QString::fromStdString(m_unityFilterOption->icon_hint());
}

bool FilterOption::active() const
{
    return m_unityFilterOption->active();
}

void FilterOption::setActive(bool active)
{
    m_unityFilterOption->active = active;
}

void FilterOption::setUnityFilterOption(unity::dash::FilterOption::Ptr unityFilterOption)
{
    if (m_unityFilterOption != NULL) {
        // FIXME: should disconnect from m_unityFilterOption's signals
    }

    m_unityFilterOption = unityFilterOption;

    /* Property change signals */
    m_unityFilterOption->id.changed.connect(sigc::mem_fun(this, &FilterOption::idChanged));
    m_unityFilterOption->name.changed.connect(sigc::mem_fun(this, &FilterOption::nameChanged));
    m_unityFilterOption->icon_hint.changed.connect(sigc::mem_fun(this, &FilterOption::iconHintChanged));
    m_unityFilterOption->active.changed.connect(sigc::mem_fun(this, &FilterOption::activeChanged));
}

#include "filteroption.moc"
