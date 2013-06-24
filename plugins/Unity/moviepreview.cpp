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

// local
#include "moviepreview.h"

MoviePreview::MoviePreview(QObject *parent):
    Preview(parent)
{
}

QString MoviePreview::year() const
{
    return QString::fromStdString(m_unityMoviePreview->year());
}

float MoviePreview::rating() const
{
    return m_unityMoviePreview->rating();
}

unsigned int MoviePreview::numRatings() const
{
    return m_unityMoviePreview->num_ratings();
}

    
void MoviePreview::setUnityPreview(unity::dash::Preview::Ptr unityPreview)
{
    Preview::setUnityPreview(unityPreview);

    m_unityMoviePreview = std::dynamic_pointer_cast<unity::dash::MoviePreview>(unityPreview);
}
