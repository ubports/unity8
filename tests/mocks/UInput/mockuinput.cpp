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


#include "mockuinput.h"

#include <QFile>
#include <QDebug>
#include <QDateTime>

#include <unistd.h>

MockUInput::MockUInput(QObject *parent) :
    QObject(parent)
{
}

MockUInput::~MockUInput()
{
}

void MockUInput::createMouse()
{
    if (m_mouseCreated) {
        qDebug() << "Already have a virtual device. Not creating another one.";
        return;
    }
    m_mouseCreated = true;
    Q_EMIT mouseCreated();
}

void MockUInput::removeMouse()
{
    if (!m_mouseCreated) {
        return;
    }
    qDebug() << "Virtual uinput mouse device removed.";
    m_mouseCreated = false;
    Q_EMIT mouseRemoved();
}

void MockUInput::moveMouse(int dx, int dy)
{
    Q_EMIT mouseMoved(dx, dy);
}

void MockUInput::pressMouse(Button button)
{
    Q_EMIT mousePressed(button);
}

void MockUInput::releaseMouse(Button button)
{
    Q_EMIT mouseReleased(button);
}

void MockUInput::scrollMouse(int dh, int dv)
{
    Q_EMIT mouseScrolled(dh, dv);
}
