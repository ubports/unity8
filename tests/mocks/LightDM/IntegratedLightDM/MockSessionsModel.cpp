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
 *
 */

#include "MockSessionsModel.h"
#include <QLightDM/SessionsModel>


int MockSessionsModel::numSessions() const
{
    QLightDM::SessionsModel* qSessionsModel =
        static_cast<QLightDM::SessionsModel*>(sourceModel());

    return qSessionsModel->numSessions();
}

int MockSessionsModel::numAvailableSessions() const
{
    QLightDM::SessionsModel* qSessionsModel =
        static_cast<QLightDM::SessionsModel*>(sourceModel());

    return qSessionsModel->numAvailableSessions();
}

QString MockSessionsModel::testScenario() const
{
    QLightDM::SessionsModel* qSessionsModel =
        static_cast<QLightDM::SessionsModel*>(sourceModel());

    return qSessionsModel->testScenario();
}

void MockSessionsModel::setNumSessions(const int numSessions)
{
    QLightDM::SessionsModel* qSessionsModel =
        static_cast<QLightDM::SessionsModel*>(sourceModel());

    if (qSessionsModel->numSessions() != numSessions) {
        qSessionsModel->setNumSessions(numSessions);
        Q_EMIT numSessionsChanged();
    }
}

void MockSessionsModel::setTestScenario(const QString testScenario)
{
    QLightDM::SessionsModel* qSessionsModel =
        static_cast<QLightDM::SessionsModel*>(sourceModel());

    if (qSessionsModel->testScenario() != testScenario) {
        qSessionsModel->setTestScenario(testScenario);
        Q_EMIT testScenarioChanged();
    }
}
