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

// libunity-core
#include <UnityCore/Filter.h>

class CombinedFilterOption : public AbstractFilterOption
{
public:
    explicit CombinedFilterOption(unity::dash::FilterOption::Ptr unityFilterOption1, unity::dash::FilterOption::Ptr unityFilterOption2 = NULL, QObject *parent = 0);

    /* getters */
    QString id() const override;
    QString name() const override;
    QString iconHint() const override;
    bool active() const override;

    /* setters */
    void setActive(bool active) override;

private Q_SLOTS:
    void onIdChanged(const std::string &id);
    void onActiveChanged(bool active);

private:
    std::string getCombinedId() const;
    std::string getCombinedName() const;
    void setUnityFilterOption(unity::dash::FilterOption::Ptr unityFilterOption1, unity::dash::FilterOption::Ptr unityFilterOption2 = NULL);

    bool m_active; //not needed???
    unity::dash::FilterOption::Ptr m_unityFilterOption[2];
};

#endif /* COMBINEDFILTEROPTION_H */
