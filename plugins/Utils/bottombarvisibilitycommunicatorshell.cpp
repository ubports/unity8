/*
 * Copyright (C) 2012 Canonical, Ltd.
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

#include "bottombarvisibilitycommunicatorshell.h"

BottomBarVisibilityCommunicatorShell::BottomBarVisibilityCommunicatorShell()
 : m_forceHidden(false),
   m_position(0)
{
}

bool BottomBarVisibilityCommunicatorShell::forceHidden() const
{
    return m_forceHidden;
}

double BottomBarVisibilityCommunicatorShell::position() const
{
    return m_position;
}

void BottomBarVisibilityCommunicatorShell::setForceHidden(bool forceHidden)
{
    if (forceHidden != m_forceHidden) {
        m_forceHidden = forceHidden;
        Q_EMIT forceHiddenChanged(forceHidden);
    }
}

void BottomBarVisibilityCommunicatorShell::setPosition(double position)
{
    if (position != m_position) {
        m_position = position;
        Q_EMIT positionChanged(position);
    }
}
