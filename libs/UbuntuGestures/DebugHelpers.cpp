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

#include "DebugHelpers.h"
#include <QTouchEvent>
#include <QMouseEvent>

QString touchPointStateToString(Qt::TouchPointState state)
{
    switch (state) {
    case Qt::TouchPointPressed:
        return QStringLiteral("pressed");
    case Qt::TouchPointMoved:
        return QStringLiteral("moved");
    case Qt::TouchPointStationary:
        return QStringLiteral("stationary");
    case Qt::TouchPointReleased:
        return QStringLiteral("released");
    default:
        return QStringLiteral("INVALID_STATE");
    }
}

QString touchEventToString(const QTouchEvent *ev)
{
    QString message;

    switch (ev->type()) {
    case QEvent::TouchBegin:
        message.append("TouchBegin ");
        break;
    case QEvent::TouchUpdate:
        message.append("TouchUpdate ");
        break;
    case QEvent::TouchEnd:
        message.append("TouchEnd ");
        break;
    case QEvent::TouchCancel:
        message.append("TouchCancel ");
        break;
    default:
        message.append("INVALID_TOUCH_EVENT_TYPE ");
    }

    foreach(const QTouchEvent::TouchPoint& touchPoint, ev->touchPoints()) {
        message.append(
            QStringLiteral("(id:%1, state:%2, scenePos:(%3,%4)) ")
                .arg(touchPoint.id())
                .arg(touchPointStateToString(touchPoint.state()))
                .arg(touchPoint.scenePos().x())
                .arg(touchPoint.scenePos().y())
            );
    }

    return message;
}

QString mouseEventToString(const QMouseEvent *ev)
{
    QString message;

    switch (ev->type()) {
    case QEvent::MouseButtonPress:
        message.append("MouseButtonPress ");
        break;
    case QEvent::MouseButtonRelease:
        message.append("MouseButtonRelease ");
        break;
    case QEvent::MouseButtonDblClick:
        message.append("MouseButtonDblClick ");
        break;
    case QEvent::MouseMove:
        message.append("MouseMove ");
        break;
    default:
        message.append("INVALID_MOUSE_EVENT_TYPE ");
    }

    message.append(QStringLiteral("pos(%1, %2)").arg(ev->x()).arg(ev->y()));

    return message;
}
