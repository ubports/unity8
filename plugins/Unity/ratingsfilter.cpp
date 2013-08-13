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
#include "ratingsfilter.h"

// local
#include "ratingfilteroption.h"
#include "ratingoptionsmodel.h"

RatingsFilter::RatingsFilter(QObject *parent) :
    Filter(parent),
    m_unityRatingsFilter(nullptr),
    m_options(nullptr)
{
}

GenericOptionsModel* RatingsFilter::options() const
{
    return m_options;
}

float RatingsFilter::rating() const
{
    if (m_unityRatingsFilter)
    {
        return m_unityRatingsFilter->rating;
    }
    return 0.0f;
}

void RatingsFilter::setUnityFilter(unity::dash::Filter::Ptr filter)
{
    Filter::setUnityFilter(filter);
    m_unityRatingsFilter = std::dynamic_pointer_cast<unity::dash::RatingsFilter>(m_unityFilter);

    delete m_options;

    m_options = new RatingOptionsModel(this);
    connect(m_options, SIGNAL(activeChanged(AbstractFilterOption *)), m_options, SLOT(ensureTheOnlyActive(AbstractFilterOption *)));
    connect(m_options, SIGNAL(activeChanged(AbstractFilterOption *)), this, SLOT(onActiveChanged(AbstractFilterOption *)));

    Q_EMIT optionsChanged();
}

void RatingsFilter::onActiveChanged(AbstractFilterOption *option)
{
    RatingFilterOption *ratingOption = dynamic_cast<RatingFilterOption*>(option);
    if (ratingOption != nullptr)
    {
        const float val = ratingOption->active() ? ratingOption->value() : 0.0f;
        m_unityRatingsFilter->rating = val;
        Q_EMIT ratingChanged(val);
    }
}
