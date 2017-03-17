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

#ifndef WINDOWMANAGER_WORKSPACE_H
#define WINDOWMANAGER_WORKSPACE_H

#include <QObject>
#include <QVariant>
#include <QPointer>

#include <memory>
#include <functional>

class WorkspaceModel;
class TopLevelWindowModel;

namespace miral { class Workspace; }

namespace unity {
    namespace shell {
        namespace application {
            class MirSurfaceInterface;
        }
    }
}

class Workspace : public QObject
{
    Q_OBJECT
    Q_PROPERTY(bool active READ isActive NOTIFY activeChanged)
    Q_PROPERTY(TopLevelWindowModel* windowModel READ windowModel NOTIFY windowModelChanged)
public:
    ~Workspace();

    virtual void assign(WorkspaceModel* model, const QVariant& index = QVariant());
    virtual void unassign();
    void release();

    virtual bool isActive() const { return m_active; }

    TopLevelWindowModel *windowModel() const { return m_windowModel; }
    std::shared_ptr<miral::Workspace> workspace() const { return m_workspace; }
    bool isAssigned() const;

public Q_SLOTS:
    virtual void activate();

Q_SIGNALS:
    void assigned();
    void unassigned();

    void activeChanged(bool);
    void windowModelChanged();

protected:
    Workspace(QObject *parent = 0);
    Workspace(Workspace const& other);

    std::shared_ptr<miral::Workspace> m_workspace;
    WorkspaceModel* m_model;
    TopLevelWindowModel* m_windowModel;
    bool m_active;

    friend class WorkspaceManager;
};

class WorkspaceProxy : public Workspace
{
    Q_OBJECT
public:
    WorkspaceProxy(Workspace*const workspace);

    Q_INVOKABLE void assign(WorkspaceModel* model, const QVariant& index = QVariant()) override;

    bool isActive() const override;
    void activate() override;

    Workspace* proxyObject() const { return m_original.data(); }

public Q_SLOTS:
    void unassign() override;

private:
    const QPointer<Workspace> m_original;
};

#endif // WINDOWMANAGER_WORKSPACE_H
