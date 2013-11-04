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
 * Authors:
 *  Michael Zanetti <michael.zanetti@canonical.com>
 */

#include "musicpreviewtrackmodel.h"

#include <QTime>

// TODO: use something from libunity once it's public
enum ResultsColumn {
    URI,
    TRACK_NO,
    TITLE,
    LENGTH,
    PLAY_STATE,
    PROGRESS
};

MusicPreviewTrackModel::MusicPreviewTrackModel(QObject *parent): DeeListModel(parent)
{
    m_roles.insert(RoleUri, "uri");
    m_roles.insert(RoleTrackNo, "trackNo");
    m_roles.insert(RoleTitle, "title");
    m_roles.insert(RoleLength, "length");
    m_roles.insert(RolePlayState, "playState");
    m_roles.insert(RoleProgress, "progress");
}

QVariant MusicPreviewTrackModel::data(const QModelIndex &index, int role) const
{
    switch(role) {
    case RoleUri:
        return DeeListModel::data(index, ResultsColumn::URI);
    case RoleTrackNo:
        return DeeListModel::data(index, ResultsColumn::TRACK_NO);
    case RoleTitle:
        return DeeListModel::data(index, ResultsColumn::TITLE);
    case RoleLength: {
        QTime length = QTime(0,0).addSecs(DeeListModel::data(index, ResultsColumn::LENGTH).toInt());
        if (length.hour() > 0) {
            return length.toString("h:mm:ss");
        }
        return length.toString("m:ss");
    }
    case RolePlayState:
        return DeeListModel::data(index, ResultsColumn::PLAY_STATE);
    case RoleProgress:
        return DeeListModel::data(index, ResultsColumn::PROGRESS);
    }
    return QVariant();
}

QHash<int, QByteArray> MusicPreviewTrackModel::roleNames() const
{
    return m_roles;
}
