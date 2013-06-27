/*
 * Copyright (C) 2013 Canonical, Ltd.
 *
 * Authors:
 *  Pawel Stolowski <pawel.stolowski@canonical.com>
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

#ifndef MUSICPREVIEW_H
#define MUSICPREVIEW_H

// local
#include "preview.h"

// Qt
#include <QObject>
#include <QMetaType>

// libunity-core
#include <UnityCore/MusicPreview.h>


// dee-qt
#include "deelistmodel.h"

class MusicPreview: public Preview
{
    Q_OBJECT

    Q_PROPERTY(DeeListModel* tracks READ tracks NOTIFY tracksChanged)

public:
    explicit MusicPreview(QObject *parent = 0);

    DeeListModel* tracks() const;

Q_SIGNALS:
    void tracksChanged();

protected:
    void setUnityPreview(unity::dash::Preview::Ptr unityPreview) override;

private Q_SLOTS:
    void onTracksModelChanged(unity::glib::Object<DeeModel> model);

private:
    unity::dash::MusicPreview::Ptr m_unityMusicPreview;
    DeeListModel *m_tracks;
};

Q_DECLARE_METATYPE(MusicPreview *)

#endif
