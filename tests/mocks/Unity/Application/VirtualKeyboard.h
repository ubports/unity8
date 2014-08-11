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

#ifndef VIRTUALKEYBOARD_H
#define VIRTUALKEYBOARD_H

#include "MirSurfaceItem.h"

class VirtualKeyboard : public MirSurfaceItem
{
    Q_OBJECT
public:
    VirtualKeyboard(State state,
                    QQuickItem *parent = 0);

    void touchEvent(QTouchEvent * event) override;

private:
    bool hasTouchInsideKeyboard(QTouchEvent *event);
};

#endif // VIRTUALKEYBOARD_H
