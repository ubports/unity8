/*
 * Copyright 2015 Canonical Ltd.
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
 *      Mirco Mueller <mirco.mueller@canonical.com>
 */

#include "MockActionModel.h"

struct ActionModelPrivate {
    QList<QString> labels;
    QList<QString> ids;
};

ActionModel::ActionModel(QObject *parent) : QStringListModel(parent), p(new ActionModelPrivate) {
}

ActionModel::~ActionModel() {
}

int ActionModel::rowCount(const QModelIndex &) const {
    return p->labels.size();
}

QVariant ActionModel::data(const QModelIndex &index, int role) const {
    if (!index.isValid())
            return QVariant();

    switch(role) {
        case RoleActionLabel:
            return QVariant(p->labels[index.row()]);

        case RoleActionId:
            return QVariant(p->ids[index.row()]);

        default:
            return QVariant();
    }
}

QHash<int, QByteArray> ActionModel::roleNames() const {
    QHash<int, QByteArray> roles;

    roles.insert(RoleActionLabel, "label");
    roles.insert(RoleActionId, "id");

    return roles;
}

QVariant ActionModel::data(int row, int role) const
{
    return data(index(row, 0), role);
}

void ActionModel::append(const QString &id, const QString &label) {
    p->ids.push_back(id);
    p->labels.push_back(label);
}

int ActionModel::getCount() const {
    return p->labels.size();
}
