/*
 * Copyright (C) 2013 Canonical, Ltd.
 *
 * Authors:
 *  Michael Zanetti <michael.zanetti@canonical.com>
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

#ifndef LAUNCHERMODELH
#define LAUNCHERMODEL_H

#include <unity/shell/launcher/LauncherModelInterface.h>

#include <QAbstractListModel>

class LauncherItem;

using namespace unity::shell::launcher;

class LauncherModel: public LauncherModelInterface
{
   Q_OBJECT

public:
    LauncherModel(QObject *parent = 0);
    ~LauncherModel();

    int rowCount(const QModelIndex &parent) const;

    QVariant data(const QModelIndex &index, int role) const;

    Q_INVOKABLE unity::shell::launcher::LauncherItemInterface* get(int index) const;
    Q_INVOKABLE void move(int oldIndex, int newIndex);

    QHash<int, QByteArray> roleNames() const;

private:
    QList<LauncherItem*> m_list;
};

#endif // LAUNCHERMODEL_H
