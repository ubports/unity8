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
#include "ratingsfilter.h"

RatingsFilter::RatingsFilter(QObject *parent) :
    Filter(parent), m_unityRatingsFilter(NULL)
{
}

float RatingsFilter::rating() const
{
    return m_unityRatingsFilter->rating();
}

void RatingsFilter::setRating(float rating)
{
    m_unityRatingsFilter->rating = rating;
}

void RatingsFilter::setUnityFilter(unity::dash::Filter::Ptr filter)
{
    if (m_unityFilter != NULL) {
        // FIXME: should disconnect from m_unityFilter's signals
    }

    Filter::setUnityFilter(filter);
    m_unityRatingsFilter = std::dynamic_pointer_cast<unity::dash::RatingsFilter>(m_unityFilter);

    /* Property change signals */
    m_unityRatingsFilter->rating.changed.connect(sigc::mem_fun(this, &RatingsFilter::ratingChanged));
}

#include "ratingsfilter.moc"
