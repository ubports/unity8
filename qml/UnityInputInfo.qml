import QtQuick 2.3
import QtSystemInfo 5.0

Item {
    id: root
    readonly property alias mice: priv.miceCount
    readonly property alias keyboards: priv.keyboardCount

    QtObject {
        id: priv

        property var mice: new Array()
        property var keyboards: new Array()

        property int miceCount: 0
        property int keyboardCount: 0

        function addMouse(devicePath) {
            mice.push(devicePath);
            miceCount++;
        }

        function addKeyboard(devicePath) {
            keyboards.push(devicePath);
            keyboardCount++;
        }

        function removeDevice(devicePath) {
            for (var i = 0; i < priv.mice.length; i++) {
                if (priv.mice[i] == devicePath) {
                    priv.mice.splice(i, 1);
                    priv.miceCount--;
                }
            }
            for (var i = 0; i < priv.keyboards.length; i++) {
                if (priv.keyboards[i] == devicePath) {
                    priv.keyboards.splice(i, 1);
                    priv.keyboardCount--;
                }
            }
        }
    }

    InputDeviceInfo {
        id: inputInfo

        onNewDevice: {
            var device = inputInfo.get(inputInfo.indexOf(devicePath));
            if (device === null) {
                return;
            }

            var hasMouse = (device.types & InputInfo.Mouse) == InputInfo.Mouse
            var hasTouchpad = (device.types & InputInfo.TouchPad) == InputInfo.TouchPad
            var hasKeyboard = (device.types & InputInfo.Keyboard) == InputInfo.Keyboard

            if (hasMouse || hasTouchpad) {
                priv.addMouse(devicePath);
            } else if (hasKeyboard) {
                // Only accepting keyboards that do not claim to be a mouse too
                // This will be a bit buggy for real hybrid devices, but doesn't
                // fall for Microsoft mice that claim to be Keyboards too.
                priv.addKeyboard(devicePath)
            }
        }
        onDeviceRemoved: {
            priv.removeDevice(devicePath)
        }
    }
}
