/*
 * Copyright (C) 2015-2016 Canonical, Ltd.
 *
 * This program is free software: you can redistribute it and/or modify it under
 * the terms of the GNU Lesser General Public License version 3, as published by
 * the Free Software Foundation.
 *
 * This program is distributed in the hope that it will be useful, but WITHOUT
 * ANY WARRANTY; without even the implied warranties of MERCHANTABILITY,
 * SATISFACTORY QUALITY, or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
 * Lesser General Public License for more details.
 *
 * You should have received a copy of the GNU Lesser General Public License
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.
 */

#include "MousePointer.h"
#include "CursorImageProvider.h"
#include "InputDispatcherFilter.h"

#include <QQuickWindow>

// Unity API
#include <unity/shell/application/MirPlatformCursor.h>

MousePointer::MousePointer(QQuickItem *parent)
    : MirMousePointerInterface(parent)
    , m_cursorName(QStringLiteral("left_ptr"))
    , m_themeName(QStringLiteral("default"))
{
    InputDispatcherFilter::instance()->registerPointer(this);

    auto mouseMovedFunc = [this]() {
        if (!isEnabled() || !window()) return;
        QPointF globalPosition =  mapToItem(nullptr, QPointF(0, 0));
        InputDispatcherFilter::instance()->setPosition(globalPosition);
        Q_EMIT mouseMoved();
    };
    connect(this, &QQuickItem::xChanged, this, mouseMovedFunc);
    connect(this, &QQuickItem::yChanged, this, mouseMovedFunc);

    connect(this, &QQuickItem::enabledChanged, this, [this]() {
        if (!isEnabled()) setVisible(false);
    });

    connect(InputDispatcherFilter::instance(), &InputDispatcherFilter::pushedLeftBoundary,
            this, [this](QScreen* screen, qreal amount, Qt::MouseButtons buttons) {
        if (window() && window()->screen() == screen) {
            Q_EMIT pushedLeftBoundary(amount, buttons);
        }
    });

    connect(InputDispatcherFilter::instance(), &InputDispatcherFilter::pushedRightBoundary,
            this, [this](QScreen* screen, qreal amount, Qt::MouseButtons buttons) {
        if (window() && window()->screen() == screen) {
            Q_EMIT pushedRightBoundary(amount, buttons);
        }
    });
}

MousePointer::~MousePointer()
{
    registerScreen(nullptr);
    InputDispatcherFilter::instance()->unregisterPointer(this);
}

void MousePointer::handleMouseEvent(ulong /*timestamp*/, QPointF /*movement*/, Qt::MouseButtons /*buttons*/,
        Qt::KeyboardModifiers /*modifiers*/)
{
}

void MousePointer::applyItemConfinement(qreal &newX, qreal &newY)
{
    Q_ASSERT(parentItem() != nullptr);

    if (m_confiningItem.isNull()) {
        return;
    }

    QRectF confiningItemGeometry(0, 0, m_confiningItem->width(), m_confiningItem->height());

    QRectF confiningRect = m_confiningItem->mapRectToItem(parentItem(), confiningItemGeometry);

    if (newX < confiningRect.x()) {
        newX = confiningRect.x();
    } else if (newX > confiningRect.right()) {
        newX = confiningRect.right();
    }

    if (newY < confiningRect.y()) {
        newY = confiningRect.y();
    } else if (newY > confiningRect.bottom()) {
        newY = confiningRect.bottom();
    }
}

void MousePointer::handleWheelEvent(ulong /*timestamp*/, QPoint /*angleDelta*/, Qt::KeyboardModifiers /*modifiers*/)
{
}

int MousePointer::topBoundaryOffset() const
{
    return m_topBoundaryOffset;
}

void MousePointer::setTopBoundaryOffset(int topBoundaryOffset)
{
    if (m_topBoundaryOffset == topBoundaryOffset)
        return;

    m_topBoundaryOffset = topBoundaryOffset;
    Q_EMIT topBoundaryOffsetChanged(topBoundaryOffset);
}

void MousePointer::itemChange(ItemChange change, const ItemChangeData &value)
{
    if (change == ItemSceneChange) {
        registerWindow(value.window);
    }
}

void MousePointer::registerWindow(QWindow *window)
{
    if (window == m_registeredWindow) {
        return;
    }

    if (m_registeredWindow) {
        m_registeredWindow->disconnect(this);
    }

    m_registeredWindow = window;

    if (m_registeredWindow) {
        connect(window, &QWindow::screenChanged, this, &MousePointer::registerScreen);
        registerScreen(window->screen());
    } else {
        registerScreen(nullptr);
    }
}

void MousePointer::registerScreen(QScreen *screen)
{
    if (m_registeredScreen == screen) {
        return;
    }

    if (m_registeredScreen) {
        auto previousCursor = dynamic_cast<MirPlatformCursor*>(m_registeredScreen->handle()->cursor());
        if (previousCursor) {
            previousCursor->unregisterMousePointer(this);
        } else {
            qCritical("QPlatformCursor is not a MirPlatformCursor! Cursor module only works in a Mir server.");
        }
    }

    m_registeredScreen = screen;

    if (m_registeredScreen) {
        auto cursor = dynamic_cast<MirPlatformCursor*>(m_registeredScreen->handle()->cursor());
        if (cursor) {
            cursor->registerMousePointer(this);
        } else {
            qCritical("QPlaformCursor is not a MirPlatformCursor! Cursor module only works in Mir.");
        }
    }
}

void MousePointer::setCursorName(const QString &cursorName)
{
    if (cursorName != m_cursorName) {
        m_cursorName = cursorName;
        Q_EMIT cursorNameChanged(m_cursorName);
    }
}

void MousePointer::setThemeName(const QString &themeName)
{
    if (m_themeName != themeName) {
        m_themeName = themeName;
        Q_EMIT themeNameChanged(m_themeName);
    }
}

void MousePointer::setCustomCursor(const QCursor &customCursor)
{
    CursorImageProvider::instance()->setCustomCursor(customCursor);
}

QQuickItem* MousePointer::confiningItem() const
{
    return m_confiningItem.data();
}

void MousePointer::setConfiningItem(QQuickItem *item)
{
    if (item != m_confiningItem) {
        m_confiningItem = item;
        Q_EMIT confiningItemChanged();
    }
}
