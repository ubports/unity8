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
#include "filteroption.h"

// libunity-core
#include <UnityCore/Filter.h>

FilterOption::FilterOption(unity::dash::FilterOption::Ptr unityFilterOption, QObject *parent) :
    AbstractFilterOption(parent), m_unityFilterOption(nullptr)
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
    if (m_unityFilterOption != nullptr) {
        m_signals.disconnectAll();
    }

    m_unityFilterOption = unityFilterOption;

    /* Property change signals */
    m_signals << m_unityFilterOption->id.changed.connect(sigc::mem_fun(this, &FilterOption::onIdChanged))
              << m_unityFilterOption->name.changed.connect(sigc::mem_fun(this, &FilterOption::onNameChanged))
              << m_unityFilterOption->icon_hint.changed.connect(sigc::mem_fun(this, &FilterOption::onIconHintChanged))
              << m_unityFilterOption->active.changed.connect(sigc::mem_fun(this, &FilterOption::onActiveChanged));
}

void FilterOption::onIdChanged(const std::string &/* id */)
{
    Q_EMIT idChanged(id());
}

void FilterOption::onNameChanged(const std::string &/* name */)
{
    Q_EMIT nameChanged(name());
}

void FilterOption::onIconHintChanged(const std::string &/* iconHint */)
{
    Q_EMIT iconHintChanged(iconHint());
}

void FilterOption::onActiveChanged(bool active)
{
    Q_EMIT activeChanged(active);
}

#include "filteroption.moc"
