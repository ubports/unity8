/*
 * Copyright (C) 2012-2013,2015-2016 Canonical, Ltd.
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

/* This class is a really tiny filter around QLightDM::UsersModel.  There are
   some operations that we want to edit a bit for the benefit of Qml.
   Specifically, we want to sort users according to realName. */

#pragma once

#include <unitysortfilterproxymodelqml.h>
#include <QObject>

class UsersModel : public UnitySortFilterProxyModelQML
{
    Q_OBJECT

public:
    explicit UsersModel(QObject* parent=0);

protected:
    bool lessThan(const QModelIndex &source_left, const QModelIndex &source_right) const override;
};
