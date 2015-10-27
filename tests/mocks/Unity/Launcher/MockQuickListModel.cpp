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

#include <MockQuickListModel.h>

using namespace unity::shell::launcher;

MockQuickListModel::MockQuickListModel(QObject *parent) :
    QuickListModelInterface(parent)
{

}

QVariant MockQuickListModel::data(const QModelIndex &index, int role) const
{
    switch (role)
    {
    case RoleLabel:
        return QString(QLatin1String("test menu entry ") + QString::number(index.row()));
    case RoleIcon:
        return QLatin1String("copy.png");
    case RoleClickable:
        return index.row() == 1 ? false : true;
    }
    return QVariant();
}

int MockQuickListModel::rowCount(const QModelIndex &parent) const
{
    Q_UNUSED(parent)
    return 4;
}
