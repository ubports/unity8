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

#ifndef FLOATING_FLICKABLE_HELPER_H
#define FLOATING_FLICKABLE_HELPER_H

#include <QObject>
#include <QPointF>

#include "UbuntuGesturesQmlGlobal.h"

class QQuickItem;

class UBUNTUGESTURESQML_EXPORT FloatingFlickableHelper : public QObject {
    Q_OBJECT

public:
    FloatingFlickableHelper(QObject *parent = nullptr);

    Q_INVOKABLE void onDragAreaTouchPosChanged(QQuickItem *flickable, const QPointF touchPosition);
    Q_INVOKABLE void onDragAreaDraggingChanged(QQuickItem *flickable, bool dragging, const QPointF touchPosition);

private:
    bool m_mousePressed;

    friend class tst_FloatingFlickable;
};

#endif
