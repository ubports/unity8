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
#include <QDebug>
#include <QTimer>

Scopes::Scopes(QObject *parent)
 : unity::shell::scopes::ScopesInterface(parent)
 , m_scopesOverview(nullptr)
 , m_loaded(false)
 , timer(this)
{
    timer.setSingleShot(true);
    timer.setInterval(100);
    QObject::connect(&timer, &QTimer::timeout, this, &Scopes::updateScopes);

    QObject::connect(this, &Scopes::rowsInserted, this, &Scopes::countChanged);
    QObject::connect(this, &Scopes::rowsRemoved, this, &Scopes::countChanged);
    QObject::connect(this, &Scopes::modelReset, this, &Scopes::countChanged);

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
    addScope(new Scope("MockScope5", "Videos this is long ab cd ef gh ij kl", true, this));
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

void Scopes::clearFavorites()
{
    if (m_scopes.size() > 0) {
        beginRemoveRows(QModelIndex(), 0, m_scopes.count()-1);
        Q_FOREACH(Scope *scope, m_scopes) {
            m_scopesOverview->setFavorite(scope, false);
        }
        m_scopes.clear();
        endRemoveRows();
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

void Scopes::addTempScope(unity::shell::scopes::ScopeInterface* scope)
{
    m_tempScopes.insert(scope);
}

void Scopes::closeScope(unity::shell::scopes::ScopeInterface* scope)
{
    Q_ASSERT(m_tempScopes.contains(scope));
    m_tempScopes.remove(scope);
}

void Scopes::setFavorite(const QString& scopeId, bool favorite)
{
    if (favorite) {
        for (Scope *scope : m_scopes) {
            // Check it's not already there
            Q_ASSERT(scope->id() != scopeId);
        }
        for (Scope *scope : m_allScopes) {
            if (scope->id() == scopeId) {
                const int index = rowCount();
                beginInsertRows(QModelIndex(), index, index);
                m_scopes << scope;
                endInsertRows();
                m_scopesOverview->setFavorite(scope, true);
                return;
            }
        }
        Q_ASSERT(false && "Unknown scopeId");
    } else {
        for (Scope *scope : m_scopes) {
            if (scope->id() == scopeId) {
                const int index = m_scopes.indexOf(scope);
                beginRemoveRows(QModelIndex(), index, index);
                m_scopes.removeAt(index);
                endRemoveRows();
                m_scopesOverview->setFavorite(scope, false);
                return;
            }
        }
        Q_ASSERT(false && "Unknown scopeId");
    }
}

void Scopes::moveFavoriteTo(const QString& scopeId, int to)
{
    int from = -1;
    for (int i = 0; i < m_scopes.count(); ++i) {
        if (m_scopes[i]->id() == scopeId) {
            from = i;
            break;
        }
    }
    Q_ASSERT(from != -1);
    beginMoveRows(QModelIndex(), from, from, QModelIndex(), to + (to > from ? 1 : 0));
    m_scopes.move(from, to);
    endMoveRows();
    m_scopesOverview->moveFavoriteTo(m_scopes[to], to);
}

QList<Scope*> Scopes::favScopes() const
{
    return m_scopes;
}

QList<Scope*> Scopes::nonFavScopes() const
{
    QList<Scope*> res;
    for (Scope *scope : m_allScopes) {
        if (!m_scopes.contains(scope))
            res << scope;
    }
    return res;
}

void Scopes::addScope(Scope* scope)
{
    int index = rowCount();
    if (scope->favorite()) {
        beginInsertRows(QModelIndex(), index, index);
        m_scopes.append(scope);
        endInsertRows();
        connect(scope, &Scope::favoriteChanged, [this, scope]{
            setFavorite(scope->id(), scope->favorite());
        });
    }
    m_allScopes.append(scope);
}
