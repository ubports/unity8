/*
 * Copyright (C) 2015 Canonical, Ltd.
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

#include "FloatingFlickable.h"

#include <private/qquickflickable_p.h>
#include "DirectionalDragArea.h"

#include <QDebug>

FloatingFlickable::FloatingFlickable(QQuickItem *parent)
    : QQuickItem(parent)
    , m_mousePressed(false)
{
    m_dragArea = new DirectionalDragArea(this);
    m_dragArea->setWidth(width());
    m_dragArea->setHeight(height());
    m_dragArea->setDirection(Direction::Horizontal);
    connect(m_dragArea, &DirectionalDragArea::touchXChanged,
        this, &FloatingFlickable::onDragAreaTouchXChanged);
    connect(m_dragArea, &DirectionalDragArea::draggingChanged,
        this, &FloatingFlickable::onDragAreaDraggingChanged);

    m_flickable = new QQuickFlickable(this);
    m_flickable->setEnabled(false);
    m_flickable->setWidth(width());
    m_flickable->setHeight(height());
    connect(m_flickable, &QQuickFlickable::contentWidthChanged,
            this, &FloatingFlickable::contentWidthChanged);
    connect(m_flickable, &QQuickFlickable::contentXChanged,
            this, &FloatingFlickable::contentXChanged);

    connect(this, &QQuickItem::widthChanged, this, &FloatingFlickable::updateChildrenWidth);
    connect(this, &QQuickItem::heightChanged, this, &FloatingFlickable::updateChildrenHeight);
}

qreal FloatingFlickable::contentWidth() const
{
    return m_flickable->contentWidth();
}

void FloatingFlickable::setContentWidth(qreal contentWidth)
{
    m_flickable->setContentWidth(contentWidth);
}

qreal FloatingFlickable::contentX() const
{
    return m_flickable->contentX();
}

void FloatingFlickable::setContentX(qreal contentX)
{
    m_flickable->setContentX(contentX);
}

void FloatingFlickable::updateChildrenWidth()
{
    m_dragArea->setWidth(width());
    m_flickable->setWidth(width());
}

void FloatingFlickable::updateChildrenHeight()
{
    m_dragArea->setHeight(height());
    m_flickable->setHeight(height());
}

void FloatingFlickable::onDragAreaTouchXChanged(qreal /*touchX*/)
{
    if (m_mousePressed) {
        QMouseEvent mouseEvent(QEvent::MouseMove,
                QPointF(m_dragArea->touchX(),m_dragArea->touchY()),
                Qt::NoButton, Qt::LeftButton, Qt::NoModifier);

        QCoreApplication::sendEvent(m_flickable, &mouseEvent);

    }
}

void FloatingFlickable::onDragAreaDraggingChanged(bool dragging)
{
    if (dragging && !m_mousePressed) {
        QMouseEvent mouseEvent(QEvent::MouseButtonPress,
                QPointF(m_dragArea->touchX(),m_dragArea->touchY()),
                Qt::LeftButton, Qt::LeftButton, Qt::NoModifier);

        QCoreApplication::sendEvent(m_flickable, &mouseEvent);
        m_mousePressed = true;

    } else if (!dragging && m_mousePressed) {
        QMouseEvent mouseEvent(QEvent::MouseButtonRelease,
                QPointF(m_dragArea->touchX(),m_dragArea->touchY()),
                Qt::LeftButton, Qt::LeftButton, Qt::NoModifier);

        QCoreApplication::sendEvent(m_flickable, &mouseEvent);
        m_mousePressed = false;
    }
}
