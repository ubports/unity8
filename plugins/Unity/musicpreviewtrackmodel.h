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

#ifndef MUSICPREVIEWTRACKMODEL_H
#define MUSICPREVIEWTRACKMODEL_H

#include "deelistmodel.h"

class Q_DECL_EXPORT MusicPreviewTrackModel : public DeeListModel
{
    Q_OBJECT
    Q_ENUMS(Roles)

public:
    explicit MusicPreviewTrackModel(QObject* parent = 0);

    enum Roles {
        RoleUri,
        RoleTrackNo,
        RoleTitle,
        RoleLength,
        RolePlayState,
        RoleProgress
    };

    QVariant data(const QModelIndex& index, int role = Qt::DisplayRole) const;

    QHash<int, QByteArray> roleNames() const;

private:
    QHash<int, QByteArray> m_roles;
};

#endif // MUSICPREVIEWTRACKMODEL_H

