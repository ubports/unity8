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

#ifndef SOCIALPREVIEW_H
#define SOCIALPREVIEW_H

// local
#include "preview.h"

// Qt
#include <QObject>
#include <QList>
#include <QMetaType>

// libunity-core
#include <UnityCore/SocialPreview.h>

class Q_DECL_EXPORT SocialPreview: public Preview
{
    Q_OBJECT

    Q_PROPERTY(QString sender READ sender NOTIFY previewChanged)
    Q_PROPERTY(QString content READ content NOTIFY previewChanged)
    Q_PROPERTY(QString avatar READ avatar NOTIFY previewChanged)

public:
    explicit SocialPreview(QObject *parent = 0);

    QString sender() const;
    QString content() const;
    QString avatar() const;
    QVariant comments();

Q_SIGNALS:
    void previewChanged();

protected:
    void setUnityPreview(unity::dash::Preview::Ptr unityPreview) override;

private:
    unity::dash::SocialPreview::Ptr m_unitySocialPreview;
    QList<QObject *> m_comments;
};

Q_DECLARE_METATYPE(SocialPreview *)

#endif
