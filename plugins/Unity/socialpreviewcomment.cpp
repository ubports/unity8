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
#include "socialpreviewcomment.h"

SocialPreviewComment::SocialPreviewComment(QObject *parent) :
    QObject(parent)
{
}

void SocialPreviewComment::setUnityComment(unity::dash::SocialPreview::CommentPtr unityComment)
{
    m_unityComment = unityComment;
}

QString SocialPreviewComment::id() const
{
    if (m_unityComment) {
        return QString::fromStdString(m_unityComment->id);
    }
    return QString();
}

QString SocialPreviewComment::displayName() const
{
    if (m_unityComment) {
        return QString::fromStdString(m_unityComment->display_name);
    }
    return QString();
}

QString SocialPreviewComment::content() const
{
    if (m_unityComment) {
        return QString::fromStdString(m_unityComment->content);
    }
    return QString();
}

QString SocialPreviewComment::time() const
{
    if (m_unityComment) {
        return QString::fromStdString(m_unityComment->time);
    }
    return QString();
}
