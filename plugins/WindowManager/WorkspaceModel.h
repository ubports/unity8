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

#ifndef WORKSPACEMODEL_H
#define WORKSPACEMODEL_H

#include <QAbstractListModel>
#include <QLoggingCategory>
#include <QPointer>

Q_DECLARE_LOGGING_CATEGORY(WORKSPACES)

class Workspace;
class ProxyWorkspaceModel;
class ProxyScreen;

class WorkspaceModel : public QAbstractListModel
{
    Q_OBJECT
    Q_PROPERTY(int count READ rowCount NOTIFY countChanged)
public:
    /**
     * @brief The Roles supported by the model
     *
     * WorkspaceRole - A workspace.
     */
    enum Roles {
        WorkspaceRole = Qt::UserRole
    };

    explicit WorkspaceModel(QObject *parent = 0);
    ~WorkspaceModel();

    void append(Workspace *workspace);
    void insert(int index, Workspace *workspace);
    void remove(Workspace* workspace);
    virtual void move(int from, int to);

    int indexOf(Workspace *workspace) const;
    Workspace* get(int index) const;

    // From QAbstractItemModel
    int rowCount(const QModelIndex &parent = QModelIndex()) const override;
    QVariant data(const QModelIndex& index, int role) const override;
    QHash<int, QByteArray> roleNames() const override {
        QHash<int, QByteArray> roleNames { {WorkspaceRole, "workspace"} };
        return roleNames;
    }

    const QVector<Workspace*>& list() const { return m_workspaces; }

    void sync(WorkspaceModel* proxy);
    void finishSync();

Q_SIGNALS:
    void countChanged();

    void workspaceInserted(int index, Workspace *workspace);
    void workspaceRemoved(Workspace *workspace);
    void workspaceMoved(int from, int to);

protected:
    void insertUnassigned(Workspace* workspace);

    QVector<Workspace*> m_workspaces;
    QSet<Workspace*> m_unassignedWorkspaces;

    friend class ProxyWorkspaceModel;
};

class ProxyWorkspaceModel : public WorkspaceModel
{
    Q_OBJECT
public:
    explicit ProxyWorkspaceModel(WorkspaceModel*const model, ProxyScreen* screen);

    Q_INVOKABLE void move(int from, int to) override;

    bool isSyncing() const;

public Q_SLOTS:
    void addWorkspace();

protected:
    const QPointer<WorkspaceModel> m_original;
    const ProxyScreen* m_screen;
};

#endif // WORKSPACEMODEL_H
