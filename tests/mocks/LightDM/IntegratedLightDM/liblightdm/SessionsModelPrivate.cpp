/*
 * Copyright (C) 2015 Canonical, Ltd.
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

#include "SessionsModel.h"
#include "SessionsModelPrivate.h"

namespace QLightDM
{

SessionsModelPrivate::SessionsModelPrivate(SessionsModel* parent)
    : testScenario("singleSession")
    , q_ptr(parent)
{
    resetEntries();
}

void SessionsModelPrivate::resetEntries()
{
    Q_Q(SessionsModel);

    q->beginResetModel();
        if (testScenario == "multipleSessions") {
            resetEntries_multipleSessions();
        } else if (testScenario == "noSessions") {
            resetEntries_noSessions();
        } else {
            resetEntries_singleSession();
        }
    q->endResetModel();
}

void SessionsModelPrivate::resetEntries_multipleSessions()
{
    sessionItems =
        {
            {"", "", "Ubuntu", ""},
            {"", "", "GNOME", ""},
            {"", "", "Plasma", ""},
            {"", "", "Unknown", ""}
        };
}

void SessionsModelPrivate::resetEntries_noSessions()
{
    sessionItems = {};
}

void SessionsModelPrivate::resetEntries_singleSession()
{
    sessionItems = {{"", "", "Ubuntu", ""}};
}

} // namespace QLightDM
