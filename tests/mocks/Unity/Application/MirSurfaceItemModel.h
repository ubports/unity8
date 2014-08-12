/*
 * Copyright (C) 2014 Canonical, Ltd.
 *
 * This program is free software: you can redistribute it and/or modify it under
 * the terms of the GNU Lesser General Public License version 3, as published by
 * the Free Software Foundation.
 *
 * This program is distributed in the hope that it will be useful, but WITHOUT
 * ANY WARRANTY; without even the implied warranties of MERCHANTABILITY,
 * SATISFACTORY QUALITY, or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
 * Lesser General Public License for more details.
 *
 * You should have received a copy of the GNU Lesser General Public License
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.
 */

#ifndef MIRSURFACEITEMMODEL_H
#define MIRSURFACEITEMMODEL_H

// Qt
#include <QAbstractListModel>

class MirSurfaceItem;

class MirSurfaceItemModel : public QAbstractListModel
{
    Q_OBJECT
    Q_ENUMS(Roles)
    Q_PROPERTY(int count READ count NOTIFY countChanged)

public:
    enum Roles {
        RoleSurface = Qt::UserRole,
    };

    explicit MirSurfaceItemModel(QObject *parent = 0);

    const QList<MirSurfaceItem*>& list() const { return m_surfaceItems; }
    bool contains(MirSurfaceItem* surface) const { return m_surfaceItems.contains(surface); }
    int count() const { return rowCount(); }

    void insertSurface(uint index, MirSurfaceItem* surface);
    void removeSurface(MirSurfaceItem* surface);

    // from QAbstractItemModel
    int rowCount(const QModelIndex & parent = QModelIndex()) const override;
    QVariant data(const QModelIndex & index, int role = Qt::DisplayRole) const override;
    QHash<int, QByteArray> roleNames() const override;

    Q_INVOKABLE MirSurfaceItem* getSurface(int index);

Q_SIGNALS:
    void countChanged();

private:
    void move(int from, int to);
    QList<MirSurfaceItem*> m_surfaceItems;
};

Q_DECLARE_METATYPE(MirSurfaceItemModel*)

#endif // MIRSURFACEITEMMODEL_H
