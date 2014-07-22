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
#include "ApplicationInfo.h"

#include <QPainter>
#include <QQmlEngine>

MirSurfaceItem::MirSurfaceItem(const QString& name,
                               MirSurfaceItem::Type type,
                               MirSurfaceItem::State state,
                               const QUrl& screenshot,
                               QQuickItem *parent)
    : QQuickPaintedItem(parent)
    , m_application(nullptr)
    , m_name(name)
    , m_type(type)
    , m_state(state)
    , m_img(screenshot.isLocalFile() ? screenshot.toLocalFile() : screenshot.toString())
    , m_parentSurface(nullptr)
{
    QQmlEngine::setObjectOwnership(this, QQmlEngine::CppOwnership);

    setFillColor(Qt::white);
}

MirSurfaceItem::~MirSurfaceItem()
{
    QList<MirSurfaceItem*> children(m_children);
    for (MirSurfaceItem* child : children) {
        child->setParentSurface(nullptr);
    }
    if (m_parentSurface)
        m_parentSurface->removeChildSurface(this);

    if (m_application)
        m_application->setSurface(nullptr);
}

void MirSurfaceItem::paint(QPainter * painter)
{
    if (!m_img.isNull()) {
        painter->drawImage(contentsBoundingRect(), m_img, QRect(QPoint(0,0), m_img.size()));
    }
}

void MirSurfaceItem::release()
{
    QList<MirSurfaceItem*> children(m_children);
    for (MirSurfaceItem* child : children) {
        child->release();
    }
    if (m_parentSurface) {
        m_parentSurface->removeChildSurface(this);
    }

    if (m_application) {
        m_application->setSurface(nullptr);
    }
    if (!parent()) {
        deleteLater();
    }
}

void MirSurfaceItem::setApplication(ApplicationInfo* application)
{
    m_application = application;
}

void MirSurfaceItem::setParentSurface(MirSurfaceItem* surface)
{
    if (m_parentSurface == surface || surface == this)
        return;

    if (m_parentSurface) {
        m_parentSurface->removeChildSurface(this);
    }

    m_parentSurface = surface;

    if (m_parentSurface) {
        m_parentSurface->addChildSurface(this);
    }
    Q_EMIT parentSurfaceChanged(surface);
}

void MirSurfaceItem::removeChildSurface(MirSurfaceItem* surface)
{
    if (m_children.contains(surface)) {
        m_children.removeOne(surface);
        Q_EMIT childSurfacesChanged();
    }
}

void MirSurfaceItem::addChildSurface(MirSurfaceItem* surface)
{
    m_children.append(surface);
    Q_EMIT childSurfacesChanged();
}

QList<QObject*> MirSurfaceItem::childSurfaces() const
{
    QList<QObject*> children;
    for(MirSurfaceItem* child : m_children) {
        children.append(child);
    }
    return children;
}
