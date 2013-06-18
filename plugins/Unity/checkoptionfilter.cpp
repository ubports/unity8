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
    Filter(parent), m_unityCheckOptionFilter(NULL), m_options(NULL)
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

void CheckOptionFilter::onOptionsChanged(unity::dash::CheckOptionFilter::CheckOptions options)
{
    if (m_options != NULL) {
        // FIXME: should disconnect from m_unityFilter's signals
        delete m_options;
        m_options = NULL;
    }
    m_options = new FilterOptions(m_unityCheckOptionFilter->options,
                                  m_unityCheckOptionFilter->option_added,
                                  m_unityCheckOptionFilter->option_removed);
    /* Property change signals */
    m_unityCheckOptionFilter->options.changed.connect(sigc::mem_fun(this, &CheckOptionFilter::onOptionsChanged));

    Q_EMIT optionsChanged();
}

#include "checkoptionfilter.moc"
