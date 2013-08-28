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

// Self
#include "multirangefilter.h"

// local
#include "unityoptionsmodel.h"

MultiRangeFilter::MultiRangeFilter(QObject *parent) :
    Filter(parent), m_unityMultiRangeFilter(nullptr), m_options(nullptr)
{
}

GenericOptionsModel* MultiRangeFilter::options() const
{
    return m_options;
}

void MultiRangeFilter::setUnityFilter(unity::dash::Filter::Ptr filter)
{
    Filter::setUnityFilter(filter);
    m_unityMultiRangeFilter = std::dynamic_pointer_cast<unity::dash::MultiRangeFilter>(m_unityFilter);

    onOptionsChanged(m_unityMultiRangeFilter->options);
}

void MultiRangeFilter::onOptionsChanged(unity::dash::MultiRangeFilter::Options options)
{
    if (m_options != nullptr) {
        m_signals.disconnectAll();
        delete m_options;
        m_options = nullptr;
    }

    m_options = new UnityOptionsModel(this, options,
                                      m_unityMultiRangeFilter->option_added,
                                      m_unityMultiRangeFilter->option_removed,
                                      m_unityMultiRangeFilter->show_all_button);

    connect(m_options, SIGNAL(activeChanged(AbstractFilterOption *)), m_options, SLOT(ensureTheOnlyActive(AbstractFilterOption *)));
    connect(m_options, SIGNAL(showAllActivated()), this, SLOT(clear()));

    /* Property change signals */
    m_signals << m_unityMultiRangeFilter->options.changed.connect(sigc::mem_fun(this, &MultiRangeFilter::onOptionsChanged));

    Q_EMIT optionsChanged();
}
