/*
 * Copyright 2013 Canonical Ltd.
 *
 * This program is free software; you can redistribute it and/or modify
 * it under the terms of the GNU Lesser General Public License as published by
 * the Free Software Foundation; version 3.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU Lesser General Public License for more details.
 *
 * You should have received a copy of the GNU Lesser General Public License
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.
 *
 * Authors:
 *      Michael Zanetti <michael.zanetti@canonical.com>
 */

#ifndef MOCKLAUNCHERMODEL_H
#define MOCKLAUNCHERMODEL_H

#include <unity/shell/launcher/LauncherModelInterface.h>

using namespace unity::shell::launcher;

class MockLauncherModel: public LauncherModelInterface
{
   Q_OBJECT

public:
    MockLauncherModel(QObject* parent = 0);
    ~MockLauncherModel();

    int rowCount(const QModelIndex& parent) const;

    QVariant data(const QModelIndex& index, int role) const;

    Q_INVOKABLE unity::shell::launcher::LauncherItemInterface *get(int index) const;
    Q_INVOKABLE void move(int oldIndex, int newIndex);
private:
    QList<LauncherItemInterface*> m_list;
};

#endif // MOCKLAUNCHERMODEL_H
