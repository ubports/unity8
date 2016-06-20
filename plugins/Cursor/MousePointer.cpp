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

// Unity API
#include <unity/shell/application/MirPlatformCursor.h>

#include <QQuickWindow>
#include <QGuiApplication>

#include <qpa/qwindowsysteminterface.h>

MousePointer::MousePointer(QQuickItem *parent)
    : MirMousePointerInterface(parent)
    , m_cursorName(QStringLiteral("left_ptr"))
    , m_themeName(QStringLiteral("default"))
{
}

void MousePointer::handleMouseEvent(ulong timestamp, QPointF movement, Qt::MouseButtons buttons,
        Qt::KeyboardModifiers modifiers)
{
    if (!parentItem()) {
        return;
    }

    if (!movement.isNull()) {
        Q_EMIT mouseMoved();
    }

    m_accumulatedMovement += movement;
    // don't apply the fractional part
    QPointF appliedMovement(int(m_accumulatedMovement.x()), int(m_accumulatedMovement.y()));
    m_accumulatedMovement -= appliedMovement;

    qreal newX = x() + appliedMovement.x();
    if (newX < 0) {
        Q_EMIT pushedLeftBoundary(qAbs(newX), buttons);
        newX = 0;
    } else if (newX > parentItem()->width()) {
        Q_EMIT pushedRightBoundary(newX - parentItem()->width(), buttons);
        newX = parentItem()->width();
    }
    setX(newX);

    qreal newY = y() + appliedMovement.y();
    if (newY < 0) {
        newY = 0;
    } else if (newY > parentItem()->height()) {
        newY = parentItem()->height();
    }
    setY(newY);

    QPointF scenePosition = mapToItem(nullptr, QPointF(0, 0));
    QWindowSystemInterface::handleMouseEvent(window(), timestamp, scenePosition /*local*/, scenePosition /*global*/,
        buttons, modifiers);
}

void MousePointer::handleWheelEvent(ulong timestamp, QPoint angleDelta, Qt::KeyboardModifiers modifiers)
{
    if (!parentItem()) {
        return;
    }

    QPointF scenePosition = mapToItem(nullptr, QPointF(0, 0));
    QWindowSystemInterface::handleWheelEvent(window(), timestamp, scenePosition /* local */, scenePosition /* global */,
            QPoint() /* pixelDelta */, angleDelta, modifiers, Qt::ScrollUpdate);
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
            previousCursor->setMousePointer(nullptr);
        } else {
            qCritical("QPlatformCursor is not a MirPlatformCursor! Cursor module only works in a Mir server.");
        }
    }

    m_registeredScreen = screen;

    if (m_registeredScreen) {
        auto cursor = dynamic_cast<MirPlatformCursor*>(m_registeredScreen->handle()->cursor());
        if (cursor) {
            cursor->setMousePointer(this);
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
