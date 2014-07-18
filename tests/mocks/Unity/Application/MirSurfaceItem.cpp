/*
 * Copyright (C) 2014 Canonical, Ltd.
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

#include "MirSurfaceItem.h"

#include <QPainter>

MirSurfaceItem::MirSurfaceItem(const QString& name,
                               MirSurfaceItem::Type type,
                               MirSurfaceItem::State state,
                               const QUrl& screenshot,
                               QQuickItem *parent)
    : QQuickPaintedItem(parent)
    , m_name(name)
    , m_type(type)
    , m_state(state)
    , m_img(screenshot.isLocalFile() ? screenshot.toLocalFile() : screenshot.toString())
{
    setFillColor(Qt::white);
}

void MirSurfaceItem::paint(QPainter * painter)
{
    if (!m_img.isNull()) {
        painter->drawImage(contentsBoundingRect(), m_img, QRect(QPoint(0,0), m_img.size()));
    }
}
