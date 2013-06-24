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
#include "preview.h"
#include "genericpreview.h"
#include "applicationpreview.h"
#include "moviepreview.h"
#include "musicpreview.h"

// Qt
#include <QDebug>

#include <UnityCore/GenericPreview.h>
#include <UnityCore/ApplicationPreview.h>
#include <UnityCore/MoviePreview.h>
#include <UnityCore/MusicPreview.h>

Preview::Preview(QObject *parent):
    QObject(parent)
{
}

void Preview::setUnityPreview(unity::dash::Preview::Ptr unityPreview)
{
    m_unityPreview = unityPreview;
}

QString Preview::title() const
{
    return QString::fromStdString(m_unityPreview->title());
}

QString Preview::subtitle () const
{
    return QString::fromStdString(m_unityPreview->subtitle());
}

Preview* Preview::newFromUnityPreview(unity::dash::Preview::Ptr unityPreview)
{
    Preview* preview = nullptr;

    if (typeid(*unityPreview) == typeid(unity::dash::GenericPreview)) {
        preview = new GenericPreview();
    }
    else if (typeid(*unityPreview) == typeid(unity::dash::MusicPreview)) {
        preview = new GenericPreview();
    }
    else if (typeid(*unityPreview) == typeid(unity::dash::MoviePreview)) {
        preview = new MoviePreview();
    }
    else if (typeid(*unityPreview) == typeid(unity::dash::ApplicationPreview)) {
        preview = new ApplicationPreview();
    } else {
        qWarning() << "Unknown preview type: " << typeid(*unityPreview).name();
        preview = new GenericPreview();
    }
    preview->setUnityPreview(unityPreview);

    return preview;
}
