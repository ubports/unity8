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

    explicit UInput(QObject *parent = 0);
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
    QString m_devName;

    bool m_mouseCreated = false;
};

#endif // UINPUT_H
