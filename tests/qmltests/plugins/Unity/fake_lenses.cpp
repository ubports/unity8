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
#include "fake_lenses.h"

// TODO: Implement remaining pieces, like Categories (i.e. LensView now gives warnings)

// Qt
#include <QTimer>

Lenses::Lenses(QObject *parent)
: QAbstractListModel(parent)
, m_loaded(false)
, timer(this)
{
    m_roles[Lenses::RoleLens] = "lens";
    m_roles[Lenses::RoleId] = "id";
    m_roles[Lenses::RoleVisible] = "visible";

    QObject::connect(this, SIGNAL(rowsInserted(const QModelIndex &, int, int)), this, SIGNAL(countChanged()));
    QObject::connect(this, SIGNAL(rowsRemoved(const QModelIndex &, int, int)), this, SIGNAL(countChanged()));
    QObject::connect(this, SIGNAL(modelReset()), this, SIGNAL(countChanged()));

    timer.setSingleShot(true);
    timer.setInterval(100);
    QObject::connect(&timer, SIGNAL(timeout()), this, SLOT(updateLenses()));
    load();
}

Lenses::~Lenses()
{
}

void Lenses::updateLenses()
{
    clear();
    addLens(new Lens("MockLens1", "People", true, this));
    addLens(new Lens("MockLens2", "Music", false, this));
    addLens(new Lens("MockLens3", "Home", true, this));
    addLens(new Lens("MockLens4", "Applications", true, this));
    addLens(new Lens("MockLens5", "Videos", true, this));

    if (!m_loaded) {
        m_loaded = true;
        Q_EMIT loadedChanged(m_loaded);
    }
}

void Lenses::clear()
{
    timer.stop();
    if (m_lenses.size() > 0) {
        beginRemoveRows(QModelIndex(), 0, m_lenses.count()-1);
        qDeleteAll(m_lenses);
        m_lenses.clear();
        endRemoveRows();
    }

    if (m_loaded) {
        m_loaded = false;
        Q_EMIT loadedChanged(m_loaded);
    }
}

void Lenses::load()
{
    timer.start();
}

QHash<int, QByteArray> Lenses::roleNames() const
{
    return m_roles;
}

int Lenses::rowCount(const QModelIndex&) const
{
    return m_lenses.count();
}

QVariant Lenses::data(const QModelIndex& index, int role) const
{
    if (!index.isValid() || index.row() >= m_lenses.size()) {
        return QVariant();
    }

    Lens* lens = m_lenses.at(index.row());

    if (role == Lenses::RoleLens) {
        return QVariant::fromValue(lens);
    } else if (role == Lenses::RoleId) {
        return QVariant::fromValue(lens->id());
    } else if (role == Lenses::RoleVisible) {
        return QVariant::fromValue(lens->visible());
    } else {
        return QVariant();
    }
}

QVariant Lenses::get(int row) const
{
    return data(QAbstractListModel::index(row), 0);
}

QVariant Lenses::get(QString const&) const
{
    return QVariant();
}

QModelIndex Lenses::parent(const QModelIndex&) const
{
    return QModelIndex();
}

bool Lenses::loaded() const
{
    return m_loaded;
}

int Lenses::count() const
{
    return rowCount();
}

void Lenses::addLens(Lens* lens)
{
    int index = rowCount();
    beginInsertRows(QModelIndex(), index, index);
    m_lenses.append(lens);
    endInsertRows();
}
