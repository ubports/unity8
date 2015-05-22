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
#include <QSet>
#include <QTimer>

class ScopesOverview;

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
    Q_INVOKABLE void clearFavorites();
    Q_INVOKABLE void load();

    QVariant data(const QModelIndex& index, int role = Qt::DisplayRole) const override;
    QModelIndex parent ( const QModelIndex & index ) const override;

    bool loaded() const override;
    int count() const override;
    unity::shell::scopes::ScopeInterface* overviewScope() const override;

    Q_INVOKABLE void setFavorite(const QString& scopeId, bool favorite) override;
    Q_INVOKABLE void moveFavoriteTo(const QString& scopeId, int index) override;

    void addTempScope(unity::shell::scopes::ScopeInterface* scope);
    Q_INVOKABLE void closeScope(unity::shell::scopes::ScopeInterface* scope) override;

    // This is used as part of implementation of the other C++ code, not API
    QList<Scope*> favScopes() const;
    QList<Scope*> nonFavScopes() const;
    Q_INVOKABLE Scope* getScopeFromAll(const QString& scope_id) const;

private Q_SLOTS:
    void updateScopes();

private:
    QList<Scope*> m_scopes; // the favorite ones
    QList<Scope*> m_allScopes;
    QSet<unity::shell::scopes::ScopeInterface*> m_tempScopes;
    ScopesOverview *m_scopesOverview;
    bool m_loaded;
    QTimer timer;
};

#endif // SCOPES_H
