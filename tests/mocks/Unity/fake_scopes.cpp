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
    addScope(new Scope("MockScope3", "MS3", true, this));
    addScope(new Scope("MockScope4", "MS4", true, this));
    addScope(new Scope("MockScope6", "MS6", true, this));
    addScope(new Scope("MockScope7", "MS7", false, this));
    addScope(new Scope("MockScope8", "MS8", false, this));
    addScope(new Scope("MockScope9", "MS9", false, this));
    m_scopesOverview = new ScopesOverview(this);

    if (!m_loaded) {
        m_loaded = true;
        Q_EMIT loadedChanged();
    }
}

void Scopes::clear()
{
    timer.stop();
    if (m_scopes.size() > 0) {
        beginRemoveRows(QModelIndex(), 0, m_scopes.count()-1);
        qDeleteAll(m_scopes);
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
    } else if (role == Scopes::RoleVisible) {
        return QVariant::fromValue(scope->visible());
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
    if (scope_id == "scopesOverview") return m_scopesOverview;
    for (Scope *scope : m_scopes) {
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

QList<unity::shell::scopes::ScopeInterface *> Scopes::scopes(bool onlyVisible) const
{
    QList<unity::shell::scopes::ScopeInterface *> res;
    for (Scope *scope : m_scopes) {
        if (!onlyVisible || scope->visible()) {
            res << scope;
        }
    }
    return res;
}

void Scopes::addScope(Scope* scope)
{
    int index = rowCount();
    beginInsertRows(QModelIndex(), index, index);
    m_scopes.append(scope);
    endInsertRows();
}
