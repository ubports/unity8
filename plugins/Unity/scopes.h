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

#ifndef SCOPES_H
#define SCOPES_H

// Qt
#include <QAbstractListModel>
#include <QList>

// libunity-core
#include <UnityCore/Scope.h>
#include <UnityCore/GSettingsScopes.h>

namespace unity
{
namespace dash
{
class Scopes;
}
}

class Hotkey;
class Scope;

class Scopes : public QAbstractListModel
{
    Q_OBJECT

    Q_ENUMS(Roles)

    Q_PROPERTY(bool loaded READ loaded NOTIFY loadedChanged)

public:
    explicit Scopes(QObject *parent = 0);
    ~Scopes() = default;

    enum Roles {
        RoleLens,
        RoleId,
        RoleVisible
    };

    QVariant data(const QModelIndex& index, int role = Qt::DisplayRole) const;
    Q_INVOKABLE int rowCount(const QModelIndex& parent = QModelIndex()) const;

    Q_INVOKABLE QVariant get(int row) const;
    Q_INVOKABLE QVariant get(const QString& scope_id) const;

    QHash<int, QByteArray> roleNames() const;

    bool loaded() const;

Q_SIGNALS:
    void activateScopeRequested(const QString& scope_id);
    void loadedChanged(bool loaded);

private Q_SLOTS:
    void onScopesLoaded();
    void onScopeAdded(const unity::dash::Scope::Ptr& scope, int position);
    void onScopeRemoved(const unity::dash::Scope::Ptr& scope);
    void onScopesReordered(const unity::dash::Scopes::ScopeList& scopes);
    void onScopePropertyChanged();

private:
    unity::dash::GSettingsScopesReader::Ptr m_scopesReader;
    unity::dash::Scopes::Ptr m_unityScopes;
    QList<Scope*> m_scopes;
    QHash<int, QByteArray> m_roles;
    bool m_loaded;

    void addUnityScope(const unity::dash::Scope::Ptr& unity_scope);
    void removeUnityScope(int index);
};

#endif // SCOPES_H
