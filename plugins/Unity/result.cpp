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

#include "result.h"
#include "variantutils.h"

Result::Result(QObject *parent) :
    QObject(parent)
{
}

Result::Result(unity::dash::Preview::Ptr preview, QObject *parent) :
    QObject(parent),
    m_preview(preview)
{
}

void Result::setPreview(unity::dash::Preview::Ptr preview)
{
    m_preview = preview;
}

QString Result::uri() const
{
    return m_preview != nullptr ? QString::fromStdString(m_preview->preview_result.uri) : QString::null;
}

QString Result::iconHint() const
{
    return m_preview != nullptr ? QString::fromStdString(m_preview->preview_result.icon_hint) : QString::null;
}

unsigned Result::categoryIndex() const
{
    return m_preview != nullptr ? m_preview->preview_result.category_index : 0;
}

unsigned Result::resultType() const
{
    return m_preview != nullptr ? m_preview->preview_result.result_type : 0;
}

QString Result::mimeType() const
{
    return m_preview != nullptr ? QString::fromStdString(m_preview->preview_result.mimetype) : QString::null;
}

QString Result::title() const
{
    return m_preview != nullptr ? QString::fromStdString(m_preview->preview_result.name) : QString::null;
}

QString Result::comment() const
{
    return m_preview != nullptr ? QString::fromStdString(m_preview->preview_result.comment) : QString::null;
}

QString Result::dndUri() const
{
    return m_preview != nullptr ? QString::fromStdString(m_preview->preview_result.dnd_uri) : QString::null;
}

QVariant Result::metadata() const
{
    return m_preview != nullptr ? convertToQVariantHash(m_preview->preview_result.hints) : QVariant();
}
