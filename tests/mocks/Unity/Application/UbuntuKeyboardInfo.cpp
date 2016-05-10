/*
 * Copyright (C) 2014-2015 Canonical, Ltd.
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

UbuntuKeyboardInfo::UbuntuKeyboardInfo(QObject *parent)
    : QObject(parent),
    m_x(0),
    m_y(0),
    m_width(200),
    m_height(200)
{
}

void UbuntuKeyboardInfo::setX(qreal value)
{
    if (value != m_x) {
        m_x = value;
        Q_EMIT xChanged(m_x);
    }
}

void UbuntuKeyboardInfo::setY(qreal value)
{
    if (value != m_y) {
        m_y = value;
        Q_EMIT yChanged(m_y);
    }
}

void UbuntuKeyboardInfo::setWidth(qreal value)
{
    if (value != m_width) {
        m_width = value;
        Q_EMIT widthChanged(m_width);
    }
}

void UbuntuKeyboardInfo::setHeight(qreal value)
{
    if (value != m_height) {
        m_height = value;
        Q_EMIT heightChanged(m_height);
    }
}
