/*
 * Copyright (C) 2016 Canonical, Ltd.
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

#ifndef SCREENWINDOW_H
#define SCREENWINDOW_H

#include <QQuickWindow>
#include <QPointer>

#include "screens.h"

class ScreenWindow : public QQuickWindow
{
    Q_OBJECT
    Q_PROPERTY(Screen *screen READ screenWrapper WRITE setScreenWrapper NOTIFY screenWrapperChanged)
public:
    ScreenWindow(QWindow *parent = 0);

    Screen *screenWrapper() const;
    void setScreenWrapper(Screen *screen);

Q_SIGNALS:
    void screenWrapperChanged();

private:
    QPointer<Screen> m_screen;
};

#endif // SCREENWINDOW_H
