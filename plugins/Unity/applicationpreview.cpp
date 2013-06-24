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
#include "applicationpreview.h"

ApplicationPreview::ApplicationPreview(QObject *parent):
    Preview(parent)
{
}

QString ApplicationPreview::lastUpdate() const
{
    return QString::fromStdString(m_unityAppPreview->last_update());
}

QString ApplicationPreview::copyright() const
{
    return QString::fromStdString(m_unityAppPreview->copyright());
}

QString ApplicationPreview::license() const
{
    return QString::fromStdString(m_unityAppPreview->license());
}

QString ApplicationPreview::appIcon() const
{
    return QString::fromUtf8(g_icon_to_string(m_unityAppPreview->app_icon()));
}

float ApplicationPreview::rating() const
{
    return m_unityAppPreview->rating();
}

unsigned int ApplicationPreview::numRatings() const
{
    return m_unityAppPreview->num_ratings();
}

