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

#include <unity/shell/scopes/ScopesInterface.h>

// Local
#include "fake_scope.h"

// Qt
#include <QList>
#include <QTimer>

class Scopes : public unity::shell::scopes::ScopesInterface
{
    Q_OBJECT

public:
    explicit Scopes(QObject *parent = 0);
    ~Scopes();

    Q_INVOKABLE int rowCount(const QModelIndex& parent = QModelIndex()) const override;

    Q_INVOKABLE unity::shell::scopes::ScopeInterface* getScope(int row) const override;
    Q_INVOKABLE unity::shell::scopes::ScopeInterface* getScope(const QString& scope_id) const override;

    Q_INVOKABLE void addScope(Scope* scope);

    Q_INVOKABLE void clear();
    Q_INVOKABLE void load();

    QVariant data(const QModelIndex& index, int role = Qt::DisplayRole) const;
    QModelIndex parent ( const QModelIndex & index ) const;

    bool loaded() const override;
    unity::shell::scopes::ScopeInterface* overviewScope() const override;

private Q_SLOTS:
    void updateScopes();

private:
    QList<Scope*> m_scopes;
    bool m_loaded;
    QTimer timer;
};

#endif // SCOPES_H
