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
    , m_haveInputMethod(false)
{
    // The virtual keyboard (input method) has a big transparent area so that
    // content behind it show through
    setFillColor(Qt::transparent);

    connect(this, &QQuickItem::focusChanged,
            this, &MirSurfaceItem::onFocusChanged);
}

void MirSurfaceItem::paint(QPainter * painter)
{
    if (!m_img.isNull()) {
        painter->drawImage(contentsBoundingRect(), m_img, QRect(QPoint(0,0), m_img.size()));
    }
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
