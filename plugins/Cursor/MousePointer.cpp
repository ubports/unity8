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
#include <QQmlProperty>
#include <QtMath>

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

    const qreal newX = x() + appliedMovement.x();
    const qreal newY = y() + appliedMovement.y();
    const qreal sceneWidth = parentItem()->width();
    const qreal sceneHeight = parentItem()->height();

    if (newX <= 0 && newY < m_topBoundaryOffset) { // top left corner
        const auto distance = qSqrt(qPow(newX, 2) + qPow(newY-m_topBoundaryOffset, 2));
        Q_EMIT pushedTopLeftCorner(qAbs(distance), buttons);
    } else if (newX >= sceneWidth-1 && newY < m_topBoundaryOffset) { // top right corner
        const auto distance = qSqrt(qPow(newX-sceneWidth, 2) + qPow(newY-m_topBoundaryOffset, 2));
        Q_EMIT pushedTopRightCorner(qAbs(distance), buttons);
    } else if (newX < 0 && newY >= sceneHeight-1) { // bottom left corner
        const auto distance = qSqrt(qPow(newX, 2) + qPow(newY-sceneHeight, 2));
        Q_EMIT pushedBottomLeftCorner(qAbs(distance), buttons);
    } else if (newX >= sceneWidth-1 && newY >= sceneHeight-1) { // bottom right corner
        const auto distance = qSqrt(qPow(newX-sceneWidth, 2) + qPow(newY-sceneHeight, 2));
        Q_EMIT pushedBottomRightCorner(qAbs(distance), buttons);
    } else if (newX < 0) { // left edge
        Q_EMIT pushedLeftBoundary(qAbs(newX), buttons);
    } else if (newX >= sceneWidth) { // right edge
        Q_EMIT pushedRightBoundary(newX - (sceneWidth - 1), buttons);
    } else if (newY < m_topBoundaryOffset) { // top edge
        Q_EMIT pushedTopBoundary(qAbs(newY - m_topBoundaryOffset), buttons);
    } else if (Q_LIKELY(newX > 0 && newX < sceneWidth-1 && newY > 0 && newY < sceneHeight-1)) { // normal pos, not pushing
        Q_EMIT pushStopped();
    }

    setX(qBound(0.0, newX, sceneWidth - 1));
    setY(qBound(0.0, newY, sceneHeight - 1));

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
