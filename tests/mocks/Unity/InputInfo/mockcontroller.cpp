#include "mockcontroller.h"

#include "qinputdeviceinfo_mock_p.h"

MockController::MockController(QObject *parent):
    QObject(parent)
{

}

QInputDevice *MockController::addMockDevice(const QString &devicePath, QInputDevice::InputType type)
{
    return QInputDeviceManagerPrivate::instance()->addMockDevice(devicePath, type);
}

void MockController::removeDevice(const QString &devicePath)
{
    QInputDeviceManagerPrivate::instance()->removeDevice(devicePath);
}
