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

#include "socialpreview.h"
#include "socialpreviewcomment.h"
#include "iconutils.h"

#include <QDebug>

SocialPreview::SocialPreview(QObject *parent):
    Preview(parent),
    m_unitySocialPreview(nullptr)
{
}

QString SocialPreview::sender() const
{
    if (m_unitySocialPreview) {
        return QString::fromStdString(m_unitySocialPreview->sender());
    } else {
        qWarning() << "Preview not set";
    }
    return QString();
}

QString SocialPreview::content() const
{
    if (m_unitySocialPreview) {
        return QString::fromStdString(m_unitySocialPreview->content());
    } else {
        qWarning() << "Preview not set";
    }
    return QString();
}

QString SocialPreview::avatar() const
{
    if (m_unitySocialPreview) {
        auto giconString = g_icon_to_string(m_unitySocialPreview->avatar());
        QString result(gIconToDeclarativeImageProviderString(QString::fromUtf8(giconString)));
        g_free(giconString);
        return result;
    } else {
        qWarning() << "Preview not set";
    }
    return QString();
}

QVariant SocialPreview::comments()
{
    return QVariant::fromValue(m_comments);
}

void SocialPreview::setUnityPreview(unity::dash::Preview::Ptr unityPreview)
{
    m_unitySocialPreview = std::dynamic_pointer_cast<unity::dash::SocialPreview>(unityPreview);
    qDeleteAll(m_comments);
    m_comments.clear();

    if (m_unitySocialPreview) {
        for (auto unityComment: m_unitySocialPreview->GetComments()) {
            auto comment = new SocialPreviewComment(this);
            comment->setUnityComment(unityComment);
            m_comments.append(comment);

            Q_EMIT previewChanged();
        }
    } else {
        qWarning() << "Incorrect preview type";
    }
}
