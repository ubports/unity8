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
#include <QDebug>

CombinedFilterOption::CombinedFilterOption(unity::dash::FilterOption::Ptr unityFilterOption1, unity::dash::FilterOption::Ptr unityFilterOption2, QObject *parent)
    : AbstractFilterOption(parent),
      m_active(false),
      m_requestedActive(false),
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
        return tr("%1 - %2")
            .arg(QString::fromStdString(m_unityFilterOption[0]->name()))
            .arg(QString::fromStdString(m_unityFilterOption[1]->name())).toStdString();
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
        return m_unityFilterOption[0]->active && m_unityFilterOption[1]->active && m_requestedActive;
    return m_unityFilterOption[0]->active && m_requestedActive;
}

void CombinedFilterOption::setActive(bool active)
{
    m_requestedActive = active;
    m_unityFilterOption[0]->active = active;
    if (m_unityFilterOption[1] != NULL)
        m_unityFilterOption[1]->active = active;
}

void CombinedFilterOption::setInactive(const CombinedFilterOption &otherFilter)
{
    // de-activate underlying unity filter options as long as they don't belong
    // to otherFilter.
    if (this != &otherFilter) {
        m_requestedActive = false;
        for (int i = 0; i<2; i++) {
            if (m_unityFilterOption[i] != nullptr) {
                if (m_unityFilterOption[i]->active &&
                    m_unityFilterOption[i] != otherFilter.m_unityFilterOption[0] &&
                    m_unityFilterOption[i] != otherFilter.m_unityFilterOption[1]) {
                    m_unityFilterOption[i]->active = false;
                }
            }
        }
    }
}

void CombinedFilterOption::onIdChanged(const std::string &/* id */)
{
    Q_EMIT idChanged(getCombinedId());
}

void CombinedFilterOption::onActiveChanged(bool /*active*/)
{
    bool combinedState = CombinedFilterOption::active();
    if (m_active != combinedState) {
        m_active = combinedState;
        Q_EMIT activeChanged(m_active);
    }
}

void CombinedFilterOption::setUnityFilterOption(unity::dash::FilterOption::Ptr unityFilterOption1, unity::dash::FilterOption::Ptr unityFilterOption2)
{
    for (int i=0; i<2; i++) {
        if (m_unityFilterOption[0] != NULL) {
            m_signals.disconnectAll();
        }
    }

    m_unityFilterOption[0] = unityFilterOption1;
    m_unityFilterOption[1] = unityFilterOption2;

    /* Property change signals */
    for (int i=0; i<2; i++) {
        if (m_unityFilterOption[i] != nullptr) {
            m_signals << m_unityFilterOption[i]->id.changed.connect(sigc::mem_fun(this, &CombinedFilterOption::onIdChanged))
                      << m_unityFilterOption[i]->name.changed.connect(sigc::mem_fun(this, &CombinedFilterOption::nameChanged))
                      << m_unityFilterOption[i]->icon_hint.changed.connect(sigc::mem_fun(this,&CombinedFilterOption::iconHintChanged))
                      << m_unityFilterOption[i]->active.changed.connect(sigc::mem_fun(this, &CombinedFilterOption::onActiveChanged));
        }
    }
}
