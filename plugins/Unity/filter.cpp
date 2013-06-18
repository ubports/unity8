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
#include "filter.h"

// local
#include "ratingsfilter.h"
#include "radiooptionfilter.h"
#include "checkoptionfilter.h"
#include "multirangefilter.h"

// libunity-core
#include <UnityCore/Filter.h>
#include <UnityCore/RatingsFilter.h>
#include <UnityCore/RadioOptionFilter.h>
#include <UnityCore/CheckOptionFilter.h>
#include <UnityCore/MultiRangeFilter.h>

// Qt
#include <QDebug>

Filter::Filter(QObject *parent) :
    QObject(parent)
{
}


QString Filter::id() const
{
    return QString::fromStdString(m_unityFilter->id());
}

QString Filter::name() const
{
    return QString::fromStdString(m_unityFilter->name());
}

QString Filter::iconHint() const
{
    return QString::fromStdString(m_unityFilter->icon_hint());
}

QString Filter::rendererName() const
{
    return QString::fromStdString(m_unityFilter->renderer_name());
}

bool Filter::visible() const
{
    return m_unityFilter->visible();
}

bool Filter::collapsed() const
{
    return m_unityFilter->collapsed();
}

bool Filter::filtering() const
{
    return m_unityFilter->filtering();
}

void Filter::clear()
{
    m_unityFilter->Clear();
}


void Filter::setUnityFilter(unity::dash::Filter::Ptr unityFilter)
{
    if (m_unityFilter != NULL) {
        // FIXME: should disconnect from m_unityFilter's signals
    }

    m_unityFilter = unityFilter;

    /* Property change signals */
    m_unityFilter->id.changed.connect(sigc::mem_fun(this, &Filter::idChanged));
    m_unityFilter->name.changed.connect(sigc::mem_fun(this, &Filter::nameChanged));
    m_unityFilter->icon_hint.changed.connect(sigc::mem_fun(this, &Filter::iconHintChanged));
    m_unityFilter->renderer_name.changed.connect(sigc::mem_fun(this, &Filter::rendererNameChanged));
    m_unityFilter->visible.changed.connect(sigc::mem_fun(this, &Filter::visibleChanged));
    m_unityFilter->collapsed.changed.connect(sigc::mem_fun(this, &Filter::collapsedChanged));
    m_unityFilter->filtering.changed.connect(sigc::mem_fun(this, &Filter::filteringChanged));

    /* Signals forwarding */
    m_unityFilter->removed.connect(sigc::mem_fun(this, &Filter::removed));
}

Filter* Filter::newFromUnityFilter(unity::dash::Filter::Ptr unityFilter)
{
    Filter* filter;

    if (typeid(*unityFilter) == typeid(unity::dash::RatingsFilter)) {
        filter = new RatingsFilter;
    } else if (typeid(*unityFilter) == typeid(unity::dash::CheckOptionFilter)) {
        filter = new CheckOptionFilter;
    } else if (typeid(*unityFilter) == typeid(unity::dash::RadioOptionFilter)) {
        filter = new RadioOptionFilter;
    } else if (typeid(*unityFilter) == typeid(unity::dash::MultiRangeFilter)) {
        filter = new MultiRangeFilter;
    } else {
        qWarning() << "Filter of unknown type: " << typeid(*unityFilter).name();
        filter = new Filter;
    }

    filter->setUnityFilter(unityFilter);
    return filter;
}

bool Filter::hasUnityFilter(unity::dash::Filter::Ptr unityFilter) const
{
    return m_unityFilter == unityFilter;
}

#include "filter.moc"
