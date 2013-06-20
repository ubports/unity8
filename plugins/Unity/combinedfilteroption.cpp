/*
 * Copyright (C) 2013 Canonical, Ltd.
 *
 * Authors:
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

#include "combinedfilteroption.h"

CombinedFilterOption::CombinedFilterOption(unity::dash::FilterOption::Ptr unityFilterOption1, unity::dash::FilterOption::Ptr unityFilterOption2, QObject *parent)
    : AbstractFilterOption(parent),
      m_active(false),
      m_unityFilterOption {NULL, NULL}
{
    setUnityFilterOption(unityFilterOption1, unityFilterOption2);
}

std::string CombinedFilterOption::getCombinedId() const
{
    if (m_unityFilterOption[1] != NULL)
        return m_unityFilterOption[0]->id() + "-" + m_unityFilterOption[1]->id();
    return m_unityFilterOption[0]->id();
}

std::string CombinedFilterOption::getCombinedName() const
{
    if (m_unityFilterOption[1] != NULL)
        return m_unityFilterOption[0]->name() + " - " + m_unityFilterOption[1]->name(); //TODO i18n?
    return m_unityFilterOption[0]->name();
}

QString CombinedFilterOption::id() const
{
    return QString::fromStdString(getCombinedId());
}

QString CombinedFilterOption::name() const
{
    return QString::fromStdString(getCombinedName());
}

QString CombinedFilterOption::iconHint() const
{
    return QString::fromStdString(m_unityFilterOption[0]->icon_hint());
}

bool CombinedFilterOption::active() const
{
    if (m_unityFilterOption[1] != NULL)
        return m_unityFilterOption[0]->active && m_unityFilterOption[1]->active;
    return m_unityFilterOption[0]->active;
}

void CombinedFilterOption::setActive(bool active)
{
    m_active = active; //???
    m_unityFilterOption[0]->active;
    if (m_unityFilterOption[1] != NULL)
        m_unityFilterOption[1]->active = active;
}

void CombinedFilterOption::onIdChanged(const std::string &/* id */)
{
    Q_EMIT idChanged(getCombinedId());
}

void CombinedFilterOption::onActiveChanged(bool /*active*/)
{
    Q_EMIT activeChanged(CombinedFilterOption::active());
}

void CombinedFilterOption::setUnityFilterOption(unity::dash::FilterOption::Ptr unityFilterOption1, unity::dash::FilterOption::Ptr unityFilterOption2)
{
    for (int i=0; i<2; i++) {
        if (m_unityFilterOption[0] != NULL) {
            // FIXME: should disconnect from m_unityFilterOption's signals
        }
    }

    m_unityFilterOption[0] = unityFilterOption1;
    m_unityFilterOption[1] = unityFilterOption2;

    /* Property change signals */
    for (int i=0; i<2; i++) {
        m_unityFilterOption[i]->id.changed.connect(sigc::mem_fun(this, &CombinedFilterOption::onIdChanged));
        m_unityFilterOption[i]->name.changed.connect(sigc::mem_fun(this, &CombinedFilterOption::nameChanged));
        m_unityFilterOption[i]->icon_hint.changed.connect(sigc::mem_fun(this, &CombinedFilterOption::iconHintChanged));
        m_unityFilterOption[i]->active.changed.connect(sigc::mem_fun(this, &CombinedFilterOption::onActiveChanged));
    }
}
