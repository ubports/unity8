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

#ifndef SOCIALPREVIEWCOMMENT_H
#define SOCIALPREVIEWCOMMENT_H

// Qt
#include <QObject>
#include <QMetaType>

// libunity-core
#include <UnityCore/SocialPreview.h>

class Q_DECL_EXPORT SocialPreviewComment : public QObject
{
    Q_OBJECT

    Q_PROPERTY(QString id READ id NOTIFY socialPreviewCommentChanged)
    Q_PROPERTY(QString displayName READ displayName NOTIFY socialPreviewCommentChanged)
    Q_PROPERTY(QString content READ content NOTIFY socialPreviewCommentChanged)
    Q_PROPERTY(QString time READ time NOTIFY socialPreviewCommentChanged)

public:
    explicit SocialPreviewComment(QObject *parent = 0);
    void setUnityComment(unity::dash::SocialPreview::CommentPtr unityComment);

    QString id() const;
    QString displayName() const;
    QString content() const;
    QString time() const;

Q_SIGNALS:
    void socialPreviewCommentChanged();

private:
    unity::dash::SocialPreview::CommentPtr m_unityComment;
};

Q_DECLARE_METATYPE(SocialPreviewComment *)

#endif
