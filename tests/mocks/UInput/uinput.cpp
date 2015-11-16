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


#include "uinput.h"

#include <QFile>
#include <QDebug>
#include <QDateTime>

#include <unistd.h>

UInput::UInput(QObject *parent) :
    QObject(parent)
{
}

UInput::~UInput()
{
}

void UInput::createMouse()
{
    if (m_mouseCreated) {
        qDebug() << "Already have a virtual device. Not creating another one.";
        return;
    }
    m_mouseCreated = true;
    Q_EMIT mouseCreated();
}

void UInput::removeMouse()
{
    if (!m_mouseCreated) {
        return;
    }
    qDebug() << "Virtual uinput mouse device removed.";
    m_mouseCreated = false;
    Q_EMIT mouseRemoved();
}

void UInput::moveMouse(int dx, int dy)
{
    qDebug() << "moving mouse" << dx << dy;
    Q_EMIT mouseMoved(dx, dy);
}

void UInput::pressMouse(Button button)
{
    injectMouse(button, 1);
    Q_EMIT mousePressed(button);
}

void UInput::releaseMouse(Button button)
{
    injectMouse(button, 0);
    Q_EMIT mouseReleased(button);
}

void UInput::scrollMouse(int dh, int dv)
{
    qDebug() << "scrolling" << dh << dv;
    Q_EMIT mouseScrolled(dh, dv);
}

void UInput::injectMouse(Button button, int down)
{
    qDebug() << "mouse event" << button << down;
}
