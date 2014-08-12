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
#include "MirSurfaceItemModel.h"
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
    , m_children(new MirSurfaceItemModel(this))
    , m_haveInputMethod(false)
{
    qDebug() << "MirSurfaceItem::MirSurfaceItem() " << this->name();

    QQmlEngine::setObjectOwnership(this, QQmlEngine::CppOwnership);

    // The virtual keyboard (input method) has a big transparent area so that
    // content behind it show through
    setFillColor(Qt::transparent);

    connect(this, &QQuickItem::focusChanged,
            this, &MirSurfaceItem::onFocusChanged);
}

MirSurfaceItem::~MirSurfaceItem()
{
    qDebug() << "MirSurfaceItem::~MirSurfaceItem() " << name();
    Q_EMIT aboutToBeDestroyed();

    QList<MirSurfaceItem*> children(m_children->list());
    for (MirSurfaceItem* child : children) {
        delete child;
    }
    if (m_parentSurface) {
        m_parentSurface->removeChildSurface(this);
    }
    if (m_application) {
        m_application->removeSurface(this);
    }
    delete m_children;
}

void MirSurfaceItem::paint(QPainter * painter)
{
    if (!m_img.isNull()) {
        painter->drawImage(contentsBoundingRect(), m_img, QRect(QPoint(0,0), m_img.size()));
    }
}

void MirSurfaceItem::release()
{
    qDebug() << "MirSurfaceItem::release " << name();

    if (m_parentSurface) {
        m_parentSurface->removeChildSurface(this);
    }

    if (m_application) {
        m_application->removeSurface(this);
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

    m_parentSurface = surface;
    Q_EMIT parentSurfaceChanged(surface);
}

void MirSurfaceItem::addChildSurface(MirSurfaceItem* surface)
{
    insertChildSurface(m_children->count(), surface);
}

void MirSurfaceItem::insertChildSurface(uint index, MirSurfaceItem* surface)
{
    qDebug() << "MirSurfaceItem::insertChildSurface - " << surface->name() << " to " << name() << " @  " << index;

    surface->setParentSurface(this);
    m_children->insertSurface(index, surface);
}

void MirSurfaceItem::removeChildSurface(MirSurfaceItem* surface)
{
    qDebug() << "MirSurfaceItem::removeChildSurface - " << surface->name() << " from " << name();

    if (m_children->contains(surface)) {
        m_children->removeSurface(surface);
        surface->setParentSurface(nullptr);
    }
}

MirSurfaceItemModel* MirSurfaceItem::childSurfaces() const
{
    return m_children;
}


void MirSurfaceItem::touchEvent(QTouchEvent * event)
{
    if (event->type() == QEvent::TouchBegin && hasFocus()) {
        Q_EMIT inputMethodRequested();
        m_haveInputMethod = true;
    }
}

void MirSurfaceItem::onFocusChanged()
{
    if (!hasFocus() && m_haveInputMethod) {
        Q_EMIT inputMethodDismissed();
        m_haveInputMethod = false;
    }
}

void MirSurfaceItem::setState(MirSurfaceItem::State newState)
{
    if (newState != m_state) {
        m_state = newState;
        Q_EMIT stateChanged(newState);
    }
}
