/*
 * Copyright (C) 2014 Canonical, Ltd.
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

#include "UbuntuKeyboardInfo.h"

UbuntuKeyboardInfo *UbuntuKeyboardInfo::m_instance = nullptr;

UbuntuKeyboardInfo::UbuntuKeyboardInfo(QObject *parent)
    : QObject(parent),
    m_x(0),
    m_y(0),
    m_width(200),
    m_height(200)
{
}
