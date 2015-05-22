/*
 * Copyright (C) 2012,2013 Canonical, Ltd.
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
 * Authors: Michael Terry <michael.terry@canonical.com>
 */

/* This class is a really tiny filter around QLightDM::UsersModel.  There are
   some operations that we want to edit a bit for the benefit of Qml.
   Specifically, we want to sort users according to realName. */

#ifndef UNITY_USERSMODEL_H
#define UNITY_USERSMODEL_H

#include <unitysortfilterproxymodelqml.h>
#include <QtCore/QObject>

class UsersModel : public UnitySortFilterProxyModelQML
{
    Q_OBJECT

public:
    explicit UsersModel(QObject* parent=0);
};

#endif
