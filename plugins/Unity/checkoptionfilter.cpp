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
#include "checkoptionfilter.h"

CheckOptionFilter::CheckOptionFilter(QObject *parent) :
    Filter(parent), m_unityCheckOptionFilter(nullptr), m_options(nullptr)
{
}

FilterOptions* CheckOptionFilter::options() const
{
    return m_options;
}

void CheckOptionFilter::setUnityFilter(unity::dash::Filter::Ptr filter)
{
    Filter::setUnityFilter(filter);
    m_unityCheckOptionFilter = std::dynamic_pointer_cast<unity::dash::CheckOptionFilter>(m_unityFilter);

    onOptionsChanged(m_unityCheckOptionFilter->options);
}

void CheckOptionFilter::onOptionsChanged(unity::dash::CheckOptionFilter::CheckOptions /* options */)
{
    if (m_options != nullptr) {
        m_signals.disconnectAll();
        delete m_options;
        m_options = nullptr;
    }
    m_options = new FilterOptions(m_unityCheckOptionFilter->options,
                                  m_unityCheckOptionFilter->option_added,
                                  m_unityCheckOptionFilter->option_removed);

    Q_FOREACH(FilterOption* option, m_options->rawList()) {
        connect(option, SIGNAL(activeChanged(bool)), this, SLOT(onActiveChanged(bool)));
    }

    /* Property change signals */
    m_signals.append(m_unityCheckOptionFilter->options.changed.connect(sigc::mem_fun(this, &CheckOptionFilter::onOptionsChanged)));

    Q_EMIT optionsChanged();
}

void CheckOptionFilter::onActiveChanged(bool state)
{
    if (state == false)
        return;

    FilterOption *selected_option = dynamic_cast<FilterOption*>(QObject::sender());
    if (selected_option) {
        Q_FOREACH(FilterOption* option, m_options->rawList()) {
            if (option != selected_option && option->active()) {
                option->setActive(false);
                // we know only one option can be selected, so break immediately
                break;
            }
        }
    }
}
