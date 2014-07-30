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

#include "VirtualKeyboard.h"

#include <paths.h>

VirtualKeyboard::VirtualKeyboard(State state, QQuickItem *parent)
    : MirSurfaceItem("input-method",
            MirSurfaceItem::InputMethod,
            state,
            QString("file://%1/Dash/graphics/phone/screenshots/vkb_portrait.png").arg(qmlDirectory()),
            parent)
{
}

void VirtualKeyboard::touchEvent(QTouchEvent *event)
{
    if (event->type() == QEvent::TouchBegin && !hasTouchInsideKeyboard(event)) {
        event->ignore();
    }
}

bool VirtualKeyboard::hasTouchInsideKeyboard(QTouchEvent *event)
{
    const QList<QTouchEvent::TouchPoint> &touchPoints = event->touchPoints();
    for (int i = 0; i < touchPoints.count(); ++i) {
        QPoint pos = touchPoints.at(i).pos().toPoint();

        // Map to image coords
        int imageX = (int)( ( ((qreal)pos.x()) / width() ) * ((qreal)screenshotImage().size().width()) );
        int imageY = (int)( ( ((qreal)pos.y()) / height() ) * ((qreal)screenshotImage().size().height()) );

        QRgb pixelHit = screenshotImage().pixel(imageX, imageY);

        // The keyboard depicted in the image is in its opaque part.
        if (qAlpha(pixelHit) != 0) {
            return true;
        }
    }
    return false;
}
