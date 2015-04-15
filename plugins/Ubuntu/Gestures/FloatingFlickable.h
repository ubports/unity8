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

#ifndef FLOATING_FLICKABLE_H
#define FLOATING_FLICKABLE_H

#include <QQuickItem>
#include "UbuntuGesturesQmlGlobal.h"

class DirectionalDragArea;
class QQuickFlickable;

/*
    A Flickable that doesn't require the item being flicked to be its child.
 */
class UBUNTUGESTURESQML_EXPORT FloatingFlickable : public QQuickItem {
    Q_OBJECT

    Q_PROPERTY(qreal contentWidth READ contentWidth WRITE setContentWidth NOTIFY contentWidthChanged)
    Q_PROPERTY(qreal contentX READ contentX WRITE setContentX NOTIFY contentXChanged)

Q_SIGNALS:
    void contentWidthChanged();
    void contentXChanged();

public:
    FloatingFlickable(QQuickItem *parent = nullptr);

    qreal contentWidth() const;
    void setContentWidth(qreal contentWidth);

    qreal contentX() const;
    void setContentX(qreal contentX);

private Q_SLOTS:
    void updateChildrenWidth();
    void updateChildrenHeight();
    void onDragAreaTouchXChanged(qreal touchX);
    void onDragAreaDraggingChanged(bool value);

private:
    DirectionalDragArea *m_dragArea;
    QQuickFlickable *m_flickable;
    bool m_mousePressed;
};

#endif // FLOATING_FLICKABLE_H
