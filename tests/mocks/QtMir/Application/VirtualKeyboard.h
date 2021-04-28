/*
 * Copyright (C) 2015,2016 Canonical, Ltd.
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

#include "MirSurface.h"

#include <QQuickItem>

class VirtualKeyboard : public MirSurface
{
    Q_OBJECT
public:
    explicit VirtualKeyboard();
    ~VirtualKeyboard();

protected:
    void updateInputBoundsAfterResize() override;
};

Q_DECLARE_METATYPE(VirtualKeyboard*)

#endif // VIRTUALKEYBOARD_H
