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

#include <QQmlEngine>
#include <QQmlComponent>
#include <QQmlContext>
#include <QTimer>

MirSurfaceItem::MirSurfaceItem(const QString& name,
                               MirSurfaceItem::Type type,
                               MirSurfaceItem::State state,
                               const QString& imageQml,
                               QQuickItem *parent)
    : QQuickItem(parent)
    , m_name(name)
    , m_type(type)
    , m_state(state)
    , m_imageQml(imageQml)
    , m_imageComponent(nullptr)
    , m_imageItem(nullptr)
{
}

void MirSurfaceItem::itemChange(ItemChange change, const ItemChangeData & value)
{
    QQuickItem::itemChange(change, value);

    Q_UNUSED(value)
    if (change == QQuickItem::ItemParentHasChanged) {
        createImage();
    }
}

void MirSurfaceItem::createImage()
{
    if (!m_imageComponent) {
        QQmlContext* context = QQmlEngine::contextForObject(parentItem());
        if (!context) return;
        m_imageComponent = new QQmlComponent(context->engine(), this);
        m_imageComponent->setData(m_imageQml.toUtf8(), QUrl());
    }
    if (!m_imageItem) {
        m_imageItem = qobject_cast<QQuickItem *>(m_imageComponent->create());
        if (m_imageItem) m_imageItem->setParentItem(this);
    }
}
