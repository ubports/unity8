import QtQuick 2.2

Item {
    id: root

    function take() {
        var timeNow = new Date().getTime();
        image.source = "image://window/" + timeNow;
    }

    Image {
        id: image
    }
}

