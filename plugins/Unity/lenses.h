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

#ifndef LENSES_H
#define LENSES_H

// Qt
#include <QAbstractListModel>
#include <QList>

// libunity-core
#include <UnityCore/Lens.h>
#include <UnityCore/HomeLens.h>

namespace unity
{
namespace dash
{
class Lenses;
}
}

class Hotkey;
class Lens;

class Lenses : public QAbstractListModel
{
    Q_OBJECT

    Q_ENUMS(Roles)

    Q_PROPERTY(bool loaded READ loaded NOTIFY loadedChanged)

public:
    explicit Lenses(QObject *parent = 0);
    ~Lenses() = default;

    enum Roles {
        RoleLens,
        RoleId,
        RoleVisible
    };

    QVariant data(const QModelIndex& index, int role = Qt::DisplayRole) const;
    Q_INVOKABLE int rowCount(const QModelIndex& parent = QModelIndex()) const;

    Q_INVOKABLE QVariant get(int row) const;
    Q_INVOKABLE QVariant get(const QString& lens_id) const;

    QHash<int, QByteArray> roleNames() const;

    bool loaded() const;

Q_SIGNALS:
    void activateLensRequested(const QString& lens_id);
    void loadedChanged(bool loaded);

private Q_SLOTS:
    void onLensAdded(const unity::dash::Lens::Ptr& lens);
    void onLensesLoaded();
    void onLensPropertyChanged();

private:
    unity::dash::Lenses::Ptr m_unityLenses;
    unity::dash::HomeLens::Ptr m_homeLens;
    QList<Lens*> m_lenses;
    QHash<int, QByteArray> m_roles;
    bool m_loaded;

    void addUnityLens(const unity::dash::Lens::Ptr& unity_lens);
    void removeUnityLens(int index);
};

#endif // LENSES_H
