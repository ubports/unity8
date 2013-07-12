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

#ifndef COMBINEDFILTEROPTION_H
#define COMBINEDFILTEROPTION_H

// Local
#include "abstractfilteroption.h"
#include "signalslist.h"

// libunity-core
#include <UnityCore/Filter.h>

/**
 * Combines one or two Unity's filter options into one.
 * Becomes active if both of them are active.
 */
class Q_DECL_EXPORT CombinedFilterOption : public AbstractFilterOption
{
    Q_OBJECT

public:
    explicit CombinedFilterOption(unity::dash::FilterOption::Ptr unityFilterOption1,
                                  unity::dash::FilterOption::Ptr unityFilterOption2 = nullptr,
                                  QObject *parent = nullptr);

    /* getters */
    QString id() const override;
    QString name() const override;
    QString iconHint() const override;
    bool active() const override;

    /* setters */
    void setActive(bool active) override;

private:
    void onIdChanged(const std::string &id);
    void onNameChanged(const std::string &name);
    void onIconHintChanged(const std::string &iconHint);
    void onActiveChanged(bool active);

    QString getCombinedId() const;
    QString getCombinedName() const;
    void setUnityFilterOption(unity::dash::FilterOption::Ptr unityFilterOption1,
                              unity::dash::FilterOption::Ptr unityFilterOption2 = nullptr);

   /* De-activate the filter, and also de-activate one or both of the underlying unity's filter options, depending on whether
      one of them is active in otherFilter. This is used internally by CombinedFilterOptions to ensure only one
      CombinedFilterOption is active. */
    void setInactive(const CombinedFilterOption &otherFilter);

    bool m_active;
    bool m_requestedActive;
    unity::dash::FilterOption::Ptr m_unityFilterOption[2];
    SignalsList m_signals;

    friend class CombinedFilterOptions;
};

Q_DECLARE_METATYPE(CombinedFilterOption*)

#endif // COMBINEDFILTEROPTION_H
