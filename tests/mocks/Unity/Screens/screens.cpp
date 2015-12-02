/*
 * Copyright (C) 2015 Canonical, Ltd.
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

#include "screens.h"

// Qt
#include <QGuiApplication>
#include <QScreen>

Q_DECLARE_METATYPE(QScreen*)

Screens::Screens(QObject *parent) :
    QAbstractListModel(parent)
{
}

Screens::~Screens()
{
    qDeleteAll(m_screenList);
}

QHash<int, QByteArray> Screens::roleNames() const
{
    QHash<int, QByteArray> roles;
    roles[ScreenRole] = "screen";
    roles[OutputTypeRole] = "outputType";
    return roles;
}

QVariant Screens::data(const QModelIndex &index, int role) const
{
    if (!index.isValid() || index.row() >= m_screenList.size()) {
        return QVariant();
    }

    switch(role) {
    case ScreenRole:
        return QVariant::fromValue(m_screenList.at(index.row()));
    case OutputTypeRole:
        return OutputTypes::Unknown;
    }

    return QVariant();
}

int Screens::rowCount(const QModelIndex &) const
{
    return count();
}

int Screens::count() const
{
    return m_screenList.size();
}

void Screens::onScreenAdded(QScreen *screen)
{
    if (m_screenList.contains(screen))
        return;

    beginInsertRows(QModelIndex(), count(), count());
    m_screenList.push_back(screen);
    endInsertRows();
    Q_EMIT screenAdded(screen);
    Q_EMIT countChanged();
}

void Screens::onScreenRemoved(QScreen *screen)
{
    int index = m_screenList.indexOf(screen);
    if (index < 0)
        return;

    beginRemoveRows(QModelIndex(), index, index);
    m_screenList.removeAt(index);
    endRemoveRows();
    Q_EMIT screenRemoved(screen);
    Q_EMIT countChanged();
}
