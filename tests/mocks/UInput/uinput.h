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

Q_SIGNALS:
    // for testing
    void mouseCreated();
    void mouseRemoved();
    void mouseMoved(int dx, int dy);
    void mousePressed(Button button);
    void mouseReleased(Button button);
    void mouseScrolled(int dh, int dv);

private:
    void injectMouse(Button button, int down);

private:
    bool m_mouseCreated = false;
};

#endif // UINPUT_H
