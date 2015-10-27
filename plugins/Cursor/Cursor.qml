import QtQuick 2.4
import Cursor 1.0 // For MousePointer

MousePointer {
    id: mousePointer

    Image {
        x: -mousePointer.hotspotX
        y: -mousePointer.hotspotY
        source: "image://cursor/" + mousePointer.themeName + "/" + mousePointer.cursorName
    }
}
