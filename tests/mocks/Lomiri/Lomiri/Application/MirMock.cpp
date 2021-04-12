/*
 * Copyright (C) 2016 Canonical, Ltd.
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

#include "MirMock.h"

MirMock *MirMock::the_mir = nullptr;

MirMock *MirMock::instance()
{
    return the_mir;
}

MirMock::MirMock()
{
    Q_ASSERT(the_mir == nullptr);
    the_mir = this;
}

MirMock::~MirMock()
{
    Q_ASSERT(the_mir == this);
    the_mir = nullptr;
}

void MirMock::setCursorName(const QString &cursorName)
{
    if (cursorName != m_cursorName) {
        m_cursorName = cursorName;
        Q_EMIT cursorNameChanged(m_cursorName);
    }
}

QString MirMock::cursorName() const
{
    return m_cursorName;
}

QString MirMock::currentKeymap() const
{
    return m_keymap;
}

void MirMock::setCurrentKeymap(const QString &keymap)
{
    if (keymap != m_keymap) {
        m_keymap = keymap;
        Q_EMIT currentKeymapChanged(m_keymap);
    }
}
