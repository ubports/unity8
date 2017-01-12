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

class ScreenWindow : public QQuickWindow
{
    Q_OBJECT
    Q_PROPERTY(QScreen *screen READ screen WRITE setScreen NOTIFY screenChanged)
public:
    ScreenWindow(QWindow *parent = 0);

    QScreen *screen() const;
    void setScreen(QScreen *screen);

Q_SIGNALS:
    void screenChanged(QScreen *screen);
};

#endif // SCREENWINDOW_H
