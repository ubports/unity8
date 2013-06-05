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

#include "ubuntuwindow.h"
#include <QDebug>


UbuntuWindow::UbuntuWindow(QObject *parent)
    : QObject(parent),
      m_window(static_cast<QQuickWindow*>(parent))
{
}

int UbuntuWindow::ubuntuSurfaceRole() const
{
    return m_window->property("UbuntuSurfaceRole").toInt();
}

void UbuntuWindow::setUbuntuSurfaceRole(int ubuntuSurfaceRole)
{
    qDebug() << "setUbuntuSurfaceRole" << ubuntuSurfaceRole;
    m_window->setProperty("UbuntuSurfaceRole", ubuntuSurfaceRole);
}
