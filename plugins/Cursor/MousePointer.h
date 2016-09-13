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
    Q_PROPERTY(QQuickItem* confiningItem READ confiningItem WRITE setConfiningItem NOTIFY confiningItemChanged)
    Q_PROPERTY(int topBoundaryOffset READ topBoundaryOffset WRITE setTopBoundaryOffset NOTIFY topBoundaryOffsetChanged)
public:
    MousePointer(QQuickItem *parent = nullptr);

    void setCursorName(const QString &qtCursorName) override;
    QString cursorName() const override { return m_cursorName; }

    void setThemeName(const QString &themeName) override;
    QString themeName() const override { return m_themeName; }

    void setCustomCursor(const QCursor &) override;

    QQuickItem* confiningItem() const;
    void setConfiningItem(QQuickItem*);

    int topBoundaryOffset() const;
    void setTopBoundaryOffset(int topBoundaryOffset);

public Q_SLOTS:
    void handleMouseEvent(ulong timestamp, QPointF movement, Qt::MouseButtons buttons,
            Qt::KeyboardModifiers modifiers) override;
    void handleWheelEvent(ulong timestamp, QPoint angleDelta, Qt::KeyboardModifiers modifiers) override;

Q_SIGNALS:
    void pushedLeftBoundary(qreal amount, Qt::MouseButtons buttons);
    void pushedRightBoundary(qreal amount, Qt::MouseButtons buttons);
    void pushedTopBoundary(qreal amount, Qt::MouseButtons buttons);
    void pushedTopLeftCorner(qreal amount, Qt::MouseButtons buttons);
    void pushedTopRightCorner(qreal amount, Qt::MouseButtons buttons);
    void pushedBottomLeftCorner(qreal amount, Qt::MouseButtons buttons);
    void pushedBottomRightCorner(qreal amount, Qt::MouseButtons buttons);
    void pushStopped();
    void mouseMoved();
    void confiningItemChanged();

    void topBoundaryOffsetChanged(int topBoundaryOffset);

protected:
    void itemChange(ItemChange change, const ItemChangeData &value) override;

private Q_SLOTS:
    void registerScreen(QScreen *screen);

private:
    void registerWindow(QWindow *window);
    void applyItemConfinement(qreal &newX, qreal &newY);

    QPointer<QWindow> m_registeredWindow;
    QPointer<QScreen> m_registeredScreen;
    QString m_cursorName;
    QString m_themeName;

    // Accumulated, unapplied, mouse movement.
    QPointF m_accumulatedMovement;

    QPointer<QQuickItem> m_confiningItem;

    int m_topBoundaryOffset{0};
    bool m_pushing{false};
};

#endif // MOUSEPOINTER_H
