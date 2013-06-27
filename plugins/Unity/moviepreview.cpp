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

// Qt
#include <QDebug>

MoviePreview::MoviePreview(QObject *parent):
    Preview(parent),
    m_unityMoviePreview(nullptr)
{
}

QString MoviePreview::year() const
{
    if (m_unityMoviePreview) {
        return QString::fromStdString(m_unityMoviePreview->year());
    } else {
        qWarning() << "Preview not set";
    }
    return "";
}

float MoviePreview::rating() const
{
    if (m_unityMoviePreview) {
        return m_unityMoviePreview->rating();
    } else {
        qWarning() << "Preview not set";
    }
    return 0.0f;
}

unsigned int MoviePreview::numRatings() const
{
    if (m_unityMoviePreview) {
        return m_unityMoviePreview->num_ratings();
    } else {
        qWarning() << "Preview not set";
    }
    return 0;
}
    
void MoviePreview::setUnityPreview(unity::dash::Preview::Ptr unityPreview)
{
    m_unityMoviePreview = std::dynamic_pointer_cast<unity::dash::MoviePreview>(unityPreview);

    Q_EMIT yearChanged();
    Q_EMIT ratingChanged();
    Q_EMIT numRatingsChanged();
}
