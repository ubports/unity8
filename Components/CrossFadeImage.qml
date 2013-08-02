/*
 * Copyright (C) 2013 Canonical, Ltd.
 *
 * This program is free software; you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation; version 3.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.
 */

import QtQuick 2.0

Item {
    property url source

    /*
     * true: fade out old image in parallel with fading in the new one.
     * false: fade in new image above old one.
     *
     * The reason why this is required is that crossfading has the isse that in
     * the middle of the animation, both images are only 50% opaque which make
     * any background shine through. Not wanted for background images etc, but
     * wanted for overlays.
     */
    property bool crossFade: true

    /*
     * true: the very first source url should be faded in already.
     * false: the very first source url should just be shown without animation.
     */
    property bool fadeInFirst: true

    readonly property size sourceSize: __currentImage.sourceSize
    readonly property var status: __currentImage ? __currentImage.status : Image.Null
    readonly property bool running: crossFadeImages.running || nextImageFadeIn.running

    property Image __currentImage: image1
    property Image __nextImage: image2

    function swapImages() {
        __currentImage.z = 0
        __nextImage.z = 1
        if (crossFade) {
            crossFadeImages.start();
        } else {
            nextImageFadeIn.start();
        }

        var tmpImage = __currentImage
        __currentImage = __nextImage
        __nextImage = tmpImage
    }

    onSourceChanged: {
        // On creation, the souce handler is called before image pointers are set.
        if (__currentImage === null) {
            __currentImage = image1;
            __nextImage = image2;
        }

        crossFadeImages.stop();
        nextImageFadeIn.stop();

        // Don't fade in initial picture, only fade changes
        if (__currentImage.source == "" && !fadeInFirst) {
            __currentImage.source = source;
        } else {
            nextImageFadeIn.stop();
            __nextImage.opacity = 0.0;
            __nextImage.source = source;

            // If case the image is still in QML's cache, status will be "Ready" immediately
            if (__nextImage.status == Image.Ready || __nextImage.source == "") {
                swapImages();
            }
        }
    }

    Connections {
        target: __nextImage
        onStatusChanged: {
            if (__nextImage.status == Image.Ready || __nextImage.status == Image.Error) {
                 swapImages();
             }
        }
    }

    Image {
        id: image1
        anchors.fill: parent
        cache: false
        asynchronous: true
        fillMode: Image.PreserveAspectCrop
        z: 1
    }

    Image {
        id: image2
        anchors.fill: parent
        cache: false
        asynchronous: true
        fillMode: Image.PreserveAspectCrop
        z: 0
    }

    NumberAnimation {
        id: nextImageFadeIn
        target: __nextImage
        property: "opacity"
        duration: 400
        to: 1.0
        easing.type: Easing.InOutQuad

        onRunningChanged: {
            if (!running) {
                __nextImage.source = "";
            }
        }
    }

    ParallelAnimation {
        id: crossFadeImages
        NumberAnimation {
            target: __nextImage
            property: "opacity"
            duration: 400
            to: 1.0
            easing.type: Easing.InOutQuad
        }

        NumberAnimation {
            target: __currentImage
            property: "opacity"
            duration: 400
            to: 0
            easing.type: Easing.InOutQuad
        }

        onRunningChanged: {
            if (!running) {
                __nextImage.source = "";
            }
        }
    }
}
