/*
 * Copyright (C) 2011 Canonical, Ltd.
 *
 * Authors:
 *  Florian Boucault <florian.boucault@canonical.com>
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

// Self
#include "lenses.h"

// Local
#include "lens.h"

// Qt
#include <QDebug>
#include <QtCore/QStringList>
#include <QtGui/QKeySequence>

Scopes::Scopes(QObject *parent)
    : QAbstractListModel(parent)
    , m_unityScopes(std::make_shared<unity::dash::GSettingsScopes>())
    , m_loaded(false)
{
    m_roles[Scopes::RoleLens] = "lens";
    m_roles[Scopes::RoleId] = "id";
    m_roles[Scopes::RoleVisible] = "visible";

    m_unityScopes->scope_added.connect(sigc::mem_fun(this, &Scopes::onScopeAdded));
    m_unityScopes->scope_removed.connect(sigc::mem_fun(this, &Scopes::onScopeRemoved));
    m_unityScopes->scopes_reordered.connect(sigc::mem_fun(this, &Scopes::onScopesReordered));
    m_unityScopes->LoadScopes();
}

QHash<int, QByteArray> Scopes::roleNames() const
{
    return m_roles;
}

int Scopes::rowCount(const QModelIndex& parent) const
{
    Q_UNUSED(parent)

    return m_scopes.count();
}

QVariant Scopes::data(const QModelIndex& index, int role) const
{
    Q_UNUSED(role)

    if (!index.isValid()) {
        return QVariant();
    }

    Scope* scope = m_scopes.at(index.row());

    if (role == Scopes::RoleLens) {
        return QVariant::fromValue(scope);
    } else if (role == Scopes::RoleId) {
        return QVariant::fromValue(scope->id());
    } else if (role == Scopes::RoleVisible) {
        return QVariant::fromValue(scope->visible());
    } else {
        return QVariant();
    }
}

QVariant Scopes::get(int row) const
{
    return data(QAbstractListModel::index(row), 0);
}

QVariant Scopes::get(const QString& scope_id) const
{
    Q_FOREACH(Scope* scope, m_scopes) {
        if (scope->id() == scope_id) {
            return QVariant::fromValue(scope);
        }
    }

    return QVariant();
}

bool Scopes::loaded() const
{
    return m_loaded;
}

void Scopes::onScopeAdded(const unity::dash::Scope::Ptr& scope, int position)
{
    int index = m_scopes.count();
    beginInsertRows(QModelIndex(), index, index);
    addUnityScope(scope);
    endInsertRows();

    // FIXME: do only once after all loaded?
    m_loaded = true;
    Q_EMIT loadedChanged(m_loaded);
}

void Scopes::onScopeRemoved(const unity::dash::Scope::Ptr& scope)
{
    //TODO
}

void Scopes::onScopesReordered(const unity::dash::Scopes::ScopeList& scopes)
{
    //TODO
}

void Scopes::loadMocks()
{
    /* FIXME: this is temporary code that is required on mobile to order
       the lenses according to the design.
    */
    QStringList staticScopes;
    staticScopes << "mockmusic.lens" << "people.lens" << "home.lens" << "applications.lens" << "mockvideos.lens";

    // not all the lenses are guaranteed to go into the model (only if their UnitCore counterparts exist);
    // so build up a list of the valid ones, then add them later.
    QList<unity::dash::Scope::Ptr> added_scopes;

    // add statically ordered lenses
    Q_FOREACH(QString lensId, staticScopes) {
        unity::dash::Scope::Ptr lens = m_unityScopes->GetScope(lensId.toStdString());
        if (lens != NULL) {
            added_scopes << lens;
        }
    }

    // add remaining lenses
    unity::dash::Scopes::ScopeList scopesList = m_unityScopes->GetScopes();
    for(auto it = scopesList.begin(); it != scopesList.end(); ++it) {
        unity::dash::Scope::Ptr scope = (*it);
        if (!staticScopes.contains(QString::fromStdString(scope->id))) {
            added_scopes << scope;
        }
    }

    if (added_scopes.count() > 0) {
        int index = rowCount();
        beginInsertRows(QModelIndex(), index, index+added_scopes.count()-1);
        Q_FOREACH(unity::dash::Scope::Ptr scope, added_scopes) {
            addUnityScope(scope);
        }
        endInsertRows();
        }

    m_loaded = true;
    Q_EMIT loadedChanged(m_loaded);
}

void Scopes::onScopePropertyChanged()
{
    QModelIndex scopeIndex = index(m_scopes.indexOf(qobject_cast<Scope*>(sender())));
    Q_EMIT dataChanged(scopeIndex, scopeIndex);
}

void Scopes::addUnityScope(const unity::dash::Scope::Ptr& unity_scope)
{
    Scope* scope = new Scope(this);
    scope->setUnityScope(unity_scope);
    /* DOCME */
    QObject::connect(scope, SIGNAL(visibleChanged(bool)), this, SLOT(onLensPropertyChanged()));
    m_scopes.append(scope);
}

void Scopes::removeUnityScope(int index)
{
    Scope* scope = m_scopes.takeAt(index);

    delete scope;
}
