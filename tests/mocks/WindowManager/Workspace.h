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
#include <QVariant>

#include <memory>

class WorkspaceModel;
class TopLevelWindowModel;

namespace miral { class Workspace; }

class Workspace : public QObject
{
    Q_OBJECT
    Q_PROPERTY(bool active READ isActive NOTIFY activeChanged)
public:
    ~Workspace();

    Q_INVOKABLE void assign(WorkspaceModel* model, const QVariant& index = QVariant());

    bool isActive() const { return m_active; }

public Q_SLOT:
    void activate();
    void unassign();

Q_SIGNALS:
    void assigned();
    void unassigned();

    void activeChanged(bool);

private:
    explicit Workspace(QObject *parent = 0);

    WorkspaceModel* m_model;
    bool m_active;

    friend class WorkspaceManager;
};

#endif // WORKSPACE_H
