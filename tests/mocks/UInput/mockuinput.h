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


#ifndef MOCKUINPUT_H
#define MOCKUINPUT_H

#include <QObject>
#include <QFile>

#include <linux/uinput.h>


class MockUInput : public QObject
{
    Q_OBJECT
    Q_ENUMS(Button)

public:
    enum Button {
        ButtonLeft,
        ButtonRight,
        ButtonMiddle
    };

    explicit MockUInput(QObject *parent = nullptr);
    ~MockUInput();

    Q_INVOKABLE void createMouse();
    Q_INVOKABLE void removeMouse();

    Q_INVOKABLE void moveMouse(int dx, int dy);
    Q_INVOKABLE void pressMouse(Button button);
    Q_INVOKABLE void releaseMouse(Button button);
    Q_INVOKABLE void scrollMouse(int dh, int dv);

Q_SIGNALS:
    // for testing
    void mouseCreated();
    void mouseRemoved();
    void mouseMoved(int dx, int dy);
    void mousePressed(Button button);
    void mouseReleased(Button button);
    void mouseScrolled(int dh, int dv);

private:
    bool m_mouseCreated = false;
};

#endif // MOCKUINPUT_H
