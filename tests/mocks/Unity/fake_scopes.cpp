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

// Self
#include "fake_scopes.h"
#include "fake_scopesoverview.h"

// TODO: Implement remaining pieces, like Categories (i.e. LensView now gives warnings)

// Qt
#include <QTimer>

Scopes::Scopes(QObject *parent)
 : unity::shell::scopes::ScopesInterface(parent)
 , m_scopesOverview(nullptr)
 , m_loaded(false)
 , timer(this)
{
    timer.setSingleShot(true);
    timer.setInterval(100);
    QObject::connect(&timer, SIGNAL(timeout()), this, SLOT(updateScopes()));

    QObject::connect(this, SIGNAL(rowsInserted(const QModelIndex &, int, int)), this, SIGNAL(countChanged()));
    QObject::connect(this, SIGNAL(rowsRemoved(const QModelIndex &, int, int)), this, SIGNAL(countChanged()));
    QObject::connect(this, SIGNAL(modelReset()), this, SIGNAL(countChanged()));

    load();
}

Scopes::~Scopes()
{
}

void Scopes::updateScopes()
{
    clear();
    addScope(new Scope("MockScope1", "People", true, this));
    addScope(new Scope("MockScope2", "Music", false, this));
    addScope(new Scope("clickscope", "Apps", true, this));
    addScope(new Scope("MockScope5", "Videos", true, this));
    addScope(new Scope("SingleCategoryScope", "Single", true, this, 1));
    addScope(new Scope("MockScope4", "MS4", true, this));
    addScope(new Scope("MockScope6", "MS6", true, this));
    addScope(new Scope("MockScope7", "MS7", false, this));
    addScope(new Scope("MockScope8", "MS8", false, this));
    addScope(new Scope("MockScope9", "MS9", false, this));
    addScope(new Scope("NullPreviewScope", "NPS", false, this, 1, true));
    m_scopesOverview = new ScopesOverview(this);

    if (!m_loaded) {
        m_loaded = true;
        Q_EMIT loadedChanged();
        Q_EMIT overviewScopeChanged();
    }
}

void Scopes::clear()
{
    timer.stop();
    if (m_scopes.size() > 0) {
        beginRemoveRows(QModelIndex(), 0, m_scopes.count()-1);
        qDeleteAll(m_allScopes);
        m_allScopes.clear();
        m_scopes.clear();
        endRemoveRows();
    }
    delete m_scopesOverview;
    m_scopesOverview = nullptr;

    if (m_loaded) {
        m_loaded = false;
        Q_EMIT loadedChanged();
    }
}

void Scopes::load()
{
    timer.start();
}

int Scopes::rowCount(const QModelIndex&) const
{
    return m_scopes.count();
}

QVariant Scopes::data(const QModelIndex& index, int role) const
{
    if (!index.isValid() || index.row() >= m_scopes.size()) {
        return QVariant();
    }

    Scope* scope = m_scopes.at(index.row());

    if (role == Scopes::RoleScope) {
        return QVariant::fromValue(scope);
    } else if (role == Scopes::RoleId) {
        return QVariant::fromValue(scope->id());
    } else if (role == Scopes::RoleTitle) {
        return QVariant::fromValue(scope->name());
    } else {
        return QVariant();
    }
}

unity::shell::scopes::ScopeInterface* Scopes::getScope(int row) const
{
    if (row < 0 || row >= m_scopes.size()) {
        return nullptr;
    }

    return m_scopes[row];
}

unity::shell::scopes::ScopeInterface* Scopes::getScope(QString const &scope_id) const
{
    // According to mh3 Scopes::getScope should only return favorite scopes (i.e the ones in the model)
    for (Scope *scope : m_scopes) {
        if (scope->id() == scope_id)
            return scope;
    }
    return nullptr;
}

Scope* Scopes::getScopeFromAll(const QString& scope_id) const
{
    for (Scope *scope : m_allScopes) {
        if (scope->id() == scope_id)
            return scope;
    }
    return nullptr;
}

QModelIndex Scopes::parent(const QModelIndex&) const
{
    return QModelIndex();
}

bool Scopes::loaded() const
{
    return m_loaded;
}

int Scopes::count() const
{
    return rowCount();
}

unity::shell::scopes::ScopeInterface* Scopes::overviewScope() const
{
    return m_scopesOverview;
}

QList<Scope*> Scopes::scopes() const
{
    return m_scopes;
}

QList<Scope*> Scopes::allScopes() const
{
    return m_allScopes;
}

void Scopes::addScope(Scope* scope)
{
    int index = rowCount();
    if (scope->favorite()) {
        beginInsertRows(QModelIndex(), index, index);
        m_scopes.append(scope);
        endInsertRows();
    }
    m_allScopes.append(scope);
}
