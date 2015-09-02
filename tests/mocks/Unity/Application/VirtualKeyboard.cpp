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

#include "VirtualKeyboard.h"

#include <paths.h>

#include <QString>

#include <QDebug>

VirtualKeyboard::VirtualKeyboard()
    : MirSurface("input-method",
                     Mir::InputMethodType,
                     Mir::MinimizedState,
                     QString("file://%1/Dash/graphics/phone/screenshots/vkb_portrait.png")
                             .arg(qmlDirectory()),
                     QString("%1/Unity/Application/VirtualKeyboard.qml")
                            .arg(mockPluginsDir()))
{
}

VirtualKeyboard::~VirtualKeyboard()
{
}
