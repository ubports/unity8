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
