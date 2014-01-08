/*
 * Copyright (C) 2013 Canonical, Ltd.
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
 *
 * Author: Nick Dedekind <nick.dedekind@canonical.com>
 */

#ifndef FAKE_SCOPES_H
#define FAKE_SCOPES_H

// Local
#include "fake_scope.h"

// Qt
#include <QAbstractListModel>
#include <QList>
#include <QTimer>

class Scopes : public QAbstractListModel
{
    Q_OBJECT
    Q_ENUMS(Roles)
    Q_PROPERTY(bool loaded READ loaded NOTIFY loadedChanged)
    Q_PROPERTY(int count READ count NOTIFY countChanged)

public:
    explicit Scopes(QObject *parent = 0);
    ~Scopes();

    enum Roles {
        RoleScope,
        RoleId,
        RoleVisible,
        RoleTitle
    };

    Q_INVOKABLE int rowCount(const QModelIndex& parent = QModelIndex()) const;

    Q_INVOKABLE QVariant get(int row) const;
    Q_INVOKABLE QVariant get(const QString& scope_id) const;

    Q_INVOKABLE void addScope(Scope* scope);

    Q_INVOKABLE void clear();
    Q_INVOKABLE void load();

    QVariant data(const QModelIndex& index, int role = Qt::DisplayRole) const;
    QHash<int, QByteArray> roleNames() const;
    QModelIndex parent ( const QModelIndex & index ) const;

    bool loaded() const;
    int count() const;

Q_SIGNALS:
    void activateScopeRequested(const QString& scope_id);
    void loadedChanged(bool);
    void countChanged();

private Q_SLOTS:
    void updateScopes();

private:
    QList<Scope*> m_scopes;
    QHash<int, QByteArray> m_roles;
    bool m_loaded;
    QTimer timer;
};

#endif // SCOPES_H
