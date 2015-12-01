/*
 * Copyright (C) 2015 Canonical Ltd.
 *
 * This program is free software: you can redistribute it and/or modify it
 * under the terms of the GNU General Public License version 3, as published
 * by the Free Software Foundation.
 *
 * This program is distributed in the hope that it will be useful, but
 * WITHOUT ANY WARRANTY; without even the implied warranties of
 * MERCHANTABILITY, SATISFACTORY QUALITY, or FITNESS FOR A PARTICULAR
 * PURPOSE.  See the GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License along
 * with this program.  If not, see <http://www.gnu.org/licenses/>.
 */


#ifndef UINPUT_H
#define UINPUT_H

#include <QObject>
#include <QFile>

#include <linux/uinput.h>


class UInput : public QObject
{
    Q_OBJECT
    Q_ENUMS(Button)

public:
    enum Button {
        ButtonLeft,
        ButtonRight,
        ButtonMiddle
    };

    explicit UInput(QObject *parent = nullptr);
    ~UInput();

    Q_INVOKABLE void createMouse();
    Q_INVOKABLE void removeMouse();

    Q_INVOKABLE void moveMouse(int dx, int dy);
    Q_INVOKABLE void pressMouse(Button button);
    Q_INVOKABLE void releaseMouse(Button button);
    Q_INVOKABLE void scrollMouse(int dh, int dv);

private:
    void injectMouse(Button button, int down);

private:
    QFile m_uinput;
    uinput_user_dev m_uinput_mouse_dev;
    QByteArray m_devName;

    bool m_mouseCreated = false;
};

#endif // UINPUT_H
