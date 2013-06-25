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

#ifndef MOVIEPREVIEW_H
#define MOVIEPREVIEW_H

// local
#include "preview.h"

// Qt
#include <QObject>
#include <QMetaType>

// libunity-core
#include <UnityCore/MoviePreview.h>

class MoviePreview: public Preview
{
    Q_OBJECT

    Q_PROPERTY(QString year READ year)
    Q_PROPERTY(float rating READ rating)
    Q_PROPERTY(unsigned int numRatings READ numRatings)

public:
    explicit MoviePreview(QObject *parent = 0);

    QString year() const;
    float rating() const;
    unsigned int numRatings() const;

protected:
    void setUnityPreview(unity::dash::Preview::Ptr unityPreview) override;

private:
    unity::dash::MoviePreview::Ptr m_unityMoviePreview;
};

Q_DECLARE_METATYPE(MoviePreview *)

#endif
