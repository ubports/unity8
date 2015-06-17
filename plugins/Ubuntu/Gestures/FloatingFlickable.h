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
#include "Direction.h"

class DirectionalDragArea;
class QQuickFlickable;

/*
    A Flickable that can be put in front of the item to be flicked and
    still have the item-to-be-flicked receive input events that are not flicks.

    Ie, it's a Flickable that, input-wise, is transparent to non-flick gestures.

    With a regular Flickable you would have to make the item-to-be-flicked a child
    of Flicakble to achieve the same result. FloatingFlickable has no such requirement
    or limitation.
 */
class UBUNTUGESTURESQML_EXPORT FloatingFlickable : public QQuickItem {
    Q_OBJECT

    Q_PROPERTY(qreal contentWidth READ contentWidth WRITE setContentWidth NOTIFY contentWidthChanged)
    Q_PROPERTY(qreal contentHeight READ contentHeight WRITE setContentHeight NOTIFY contentHeightChanged)
    Q_PROPERTY(qreal contentX READ contentX WRITE setContentX NOTIFY contentXChanged)
    Q_PROPERTY(qreal contentY READ contentY WRITE setContentY NOTIFY contentYChanged)

    Q_PROPERTY(Direction::Type direction READ direction WRITE setDirection NOTIFY directionChanged)

Q_SIGNALS:
    void contentWidthChanged();
    void contentHeightChanged();
    void contentXChanged();
    void contentYChanged();
    void directionChanged();

public:
    FloatingFlickable(QQuickItem *parent = nullptr);

    qreal contentWidth() const;
    void setContentWidth(qreal contentWidth);

    qreal contentHeight() const;
    void setContentHeight(qreal contentHeight);

    qreal contentX() const;
    void setContentX(qreal contentX);

    qreal contentY() const;
    void setContentY(qreal contentY);

    Direction::Type direction() const;
    void setDirection(Direction::Type);

private Q_SLOTS:
    void updateChildrenWidth();
    void updateChildrenHeight();
    void onDragAreaTouchPosChanged(qreal);
    void onDragAreaDraggingChanged(bool value);

private:
    DirectionalDragArea *m_dragArea;
    QQuickFlickable *m_flickable;
    bool m_mousePressed;

    friend class tst_FloatingFlickable;
};

#endif // FLOATING_FLICKABLE_H
