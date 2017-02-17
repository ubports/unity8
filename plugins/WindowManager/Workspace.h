/*
 * Copyright (C) 2017 Canonical, Ltd.
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

#ifndef WORKSPACE_H
#define WORKSPACE_H

#include <QObject>

class WorkspaceModel;

class Workspace : public QObject
{
    Q_OBJECT
public:
    explicit Workspace(QObject *parent = 0);
    ~Workspace();

    Q_INVOKABLE void assign(WorkspaceModel* model);

public Q_SLOT:
    void unassign();

Q_SIGNALS:
    void assigned();
    void unassigned();

private:
    WorkspaceModel* m_model;
};

#endif // WORKSPACE_H
