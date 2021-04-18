/*
 * Copyright (C) 2016-2017 Canonical, Ltd.
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

#include "ScreenWindow.h"
#include "Screen.h"

// Qt
#include <QGuiApplication>
#include <QDebug>

ScreenWindow::ScreenWindow(QQuickWindow *parent)
    : QQuickWindow(parent)
{
}

ScreenWindow::~ScreenWindow()
{
}

ConcreteScreen *ScreenWindow::screenWrapper() const
{
    return m_screen.data();
}

void ScreenWindow::setScreenWrapper(ConcreteScreen *screen)
{
    if (m_screen != screen) {
        m_screen = screen;
        Q_EMIT screenWrapperChanged(screen);
    }
    QQuickWindow::setScreen(screen->qscreen());
}
