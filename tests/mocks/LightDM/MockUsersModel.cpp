/*
 * Copyright (C) 2014 Canonical, Ltd.
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

#include "MockUsersModel.h"
#include <QLightDM/UsersModel>
#include <QSortFilterProxyModel>

QString MockUsersModel::mockMode() const
{
    QLightDM::UsersModel* qUsersModel =
        static_cast<QLightDM::UsersModel*>(static_cast<QSortFilterProxyModel*>(sourceModel())->sourceModel());

    return qUsersModel->mockMode();
}

void MockUsersModel::setMockMode(QString mockMode)
{
    QLightDM::UsersModel* qUsersModel =
        static_cast<QLightDM::UsersModel*>(static_cast<QSortFilterProxyModel*>(sourceModel())->sourceModel());

    if (qUsersModel->mockMode() != mockMode) {
        qUsersModel->setMockMode(mockMode);
        Q_EMIT mockModeChanged(mockMode);
    }
}
