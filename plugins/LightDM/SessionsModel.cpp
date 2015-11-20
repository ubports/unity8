/*
 * Copyright (C) 2015 Canonical, Ltd.
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
 */

#include "SessionsModel.h"
#include <QtCore/QFile>
#include <QtCore/QSortFilterProxyModel>
#include <QDebug>
QHash<int, QByteArray> SessionsModel::roleNames() const
{
    return m_roleNames;
}

int SessionsModel::rowCount(const QModelIndex& parent) const
{
    return m_model->rowCount(parent);
}

QList<QUrl> SessionsModel::iconSearchDirectories() const
{
    return m_iconSearchDirectories;
}

void SessionsModel::setIconSearchDirectories(QList<QUrl> searchDirectories)
{
    m_iconSearchDirectories = searchDirectories;
    Q_EMIT iconSearchDirectoriesChanged();
}

QUrl SessionsModel::iconUrl(QString sessionName) const
{
    Q_FOREACH(const QUrl& searchDirectory, m_iconSearchDirectories)
    {
        qDebug() << "LOOKING IN: " << searchDirectory.toString();
        // This is an established icon naming convention
        QString iconUrl = searchDirectory.toString(QUrl::StripTrailingSlash) +
            "/" + sessionName.toLower()  + "_badge.png";
        QFile iconFile(iconUrl);
        if (iconFile.exists()) {
            return QUrl(iconUrl);
        }
    }

    // FIXME make this smarter
    return QUrl("./graphics/session_icons/unknown_badge.png");
}

QVariant SessionsModel::data(const QModelIndex& index, int role) const
{
    switch (role) {
        case SessionsModel::IconRole:
            return QVariant(iconUrl(m_model->data(index, Qt::DisplayRole).toString()));
        default:
            return m_model->data(index, role);
    }
}

SessionsModel::SessionsModel(QObject* parent)
  : UnitySortFilterProxyModelQML(parent)
{
    // Add a custom IconRole that isn't in either of the lightdm implementations
    m_model = new QLightDM::SessionsModel(this);
    m_roleNames = m_model->roleNames();
    m_roleNames[IconRole] = "icon_url";

    setModel(m_model);
    setSourceModel(m_model);
    setSortCaseSensitivity(Qt::CaseInsensitive);
    setSortLocaleAware(true);
    setSortRole(Qt::DisplayRole);
    sort(0);
}
