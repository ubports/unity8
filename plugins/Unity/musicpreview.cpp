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

#include "musicpreview.h"
#include <QDebug>

// dee-qt
#include "deelistmodel.h"

MusicPreview::MusicPreview(QObject *parent):
    Preview(parent),
    m_unityMusicPreview(nullptr)
{
    m_tracks = new DeeListModel(this);
}

void MusicPreview::setUnityPreview(unity::dash::Preview::Ptr unityPreview)
{
    m_unityMusicPreview = std::dynamic_pointer_cast<unity::dash::MusicPreview>(unityPreview);
    m_tracks->setModel(m_unityMusicPreview->GetTracksModel()->model());
    m_unityMusicPreview->GetTracksModel()->model.changed.connect(sigc::mem_fun(this, &MusicPreview::onTracksModelChanged));

    Q_EMIT tracksChanged();
}

DeeListModel* MusicPreview::tracks() const
{
    if (m_unityMusicPreview == nullptr) {
        qWarning() << "Preview not set";
    }
    return m_tracks;
}

void MusicPreview::onTracksModelChanged(unity::glib::Object<DeeModel> /* model */)
{
    m_tracks->setModel(m_unityMusicPreview->GetTracksModel()->model());
}
