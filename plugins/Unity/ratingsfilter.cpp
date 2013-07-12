/*
 * Copyright (C) 2011, 2013 Canonical, Ltd.
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

// local
#include "genericlistmodel.h"
#include "ratingfilteroption.h"

// Qt
#include <QDebug>

RatingsFilter::RatingsFilter(QObject *parent) :
    Filter(parent), m_unityRatingsFilter(nullptr), m_options(nullptr)
{
}

GenericListModel* RatingsFilter::options() const
{
    return m_options;
}

void RatingsFilter::setUnityFilter(unity::dash::Filter::Ptr filter)
{
    if (m_unityFilter != nullptr) {
        m_signals.disconnectAll();
    }

    Filter::setUnityFilter(filter);
    m_unityRatingsFilter = std::dynamic_pointer_cast<unity::dash::RatingsFilter>(m_unityFilter);

    if (m_options) {
        delete m_options;
    }

    m_options = new GenericListModel(this);
    for (int i=1; i<=5; i++) {
        auto opt = new RatingFilterOption(QString::number(i), i*0.2f, this);
        connect(opt, SIGNAL(activeChanged(bool)), this, SLOT(onActiveChanged()));
        m_options->addOption(opt);
    }

    Q_EMIT ratingsChanged();
}

void RatingsFilter::onActiveChanged()
{
    RatingFilterOption *option = dynamic_cast<RatingFilterOption*>(QObject::sender());
    if (option != nullptr) {
        if (option->active()) {
            // disable all other options
            for (auto it = m_options->optionsBegin(); it != m_options->optionsEnd(); it++) {
                RatingFilterOption *opt = dynamic_cast<RatingFilterOption *>(*it);
                if (opt && opt != option && opt->active()) {
                    opt->setActive(false);
                }
            }
            m_unityRatingsFilter->rating = option->value();
        }

        Q_EMIT ratingsChanged();
    } else {
        qWarning() << "Invalid option";
    }
}
