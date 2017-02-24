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

Q_DECLARE_LOGGING_CATEGORY(WORKSPACES)

class Workspace;

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

    void append(Workspace* workspace);
    void insert(int index, Workspace* workspace);
    void remove(Workspace* workspace);
    Q_INVOKABLE void move(int from, int to);

    // From QAbstractItemModel
    int rowCount(const QModelIndex &parent = QModelIndex()) const override;
    QVariant data(const QModelIndex& index, int role) const override;
    QHash<int, QByteArray> roleNames() const override {
        QHash<int, QByteArray> roleNames { {WorkspaceRole, "workspace"} };
        return roleNames;
    }

    Workspace* activeWorkspace() const;
    void setActiveWorkspace(Workspace* workspace);

Q_SIGNALS:
    void countChanged();
    void activeWorkspaceChanged();

protected:
    QVector<Workspace*> m_workspaces;
};

#endif // WORKSPACEMODEL_H
