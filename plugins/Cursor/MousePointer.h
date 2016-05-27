/*
 * Copyright (C) 2015 Canonical, Ltd.
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

#ifndef MOUSEPOINTER_H
#define MOUSEPOINTER_H

// Qt
#include <QPointer>
#include <QWindow>
#include <QScreen>

// Unity API
#include <unity/shell/application/MirMousePointerInterface.h>

class MousePointer : public MirMousePointerInterface {
    Q_OBJECT
public:
    MousePointer(QQuickItem *parent = nullptr);

    void setCursorName(const QString &qtCursorName) override;
    QString cursorName() const override { return m_cursorName; }

    void setThemeName(const QString &themeName) override;
    QString themeName() const override { return m_themeName; }

    qreal hotspotX() const override { return m_hotspotX; }
    qreal hotspotY() const override { return m_hotspotY; }

    void setCustomCursor(const QCursor &) override;

public Q_SLOTS:
    void handleMouseEvent(ulong timestamp, QPointF movement, Qt::MouseButtons buttons,
            Qt::KeyboardModifiers modifiers) override;
    void handleWheelEvent(ulong timestamp, QPoint angleDelta, Qt::KeyboardModifiers modifiers) override;

Q_SIGNALS:
    void pushedLeftBoundary(qreal amount, Qt::MouseButtons buttons);
    void pushedRightBoundary(qreal amount, Qt::MouseButtons buttons);
    void mouseMoved();

protected:
    void itemChange(ItemChange change, const ItemChangeData &value) override;

private Q_SLOTS:
    void registerScreen(QScreen *screen);

private:
    void registerWindow(QWindow *window);
    void updateHotspot();

    QPointer<QWindow> m_registeredWindow;
    QPointer<QScreen> m_registeredScreen;
    QString m_cursorName;
    QString m_themeName;
    int m_hotspotX;
    int m_hotspotY;
};

#endif // MOUSEPOINTER_H
