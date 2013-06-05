/*
 * Copyright 2013 Canonical Ltd.
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
import QtTest 1.0
import "../../../Components"

TestCase {
    name: "CrossFadeImage"

    property alias status: crossFadeImage.status
    property alias source: crossFadeImage.source
    property alias crossFade: crossFadeImage.crossFade
    property alias fadeInFirst: crossFadeImage.fadeInFirst
    property alias running: crossFadeImage.running

    CrossFadeImage {
        id: crossFadeImage
    }

    SignalSpy {
        id: signalSpy
        target: crossFadeImage
    }

    function initTestFunction(argCrossFade, argFadeInFirst) {
        source = ""
        crossFade = argCrossFade
        fadeInFirst = argFadeInFirst
        compare(status, Image.Null, "Could not reset CrossFadeImage")
    }

    function loadImage(url) {
        console.log("Loading image...")
        source = url

        signalSpy.signalName = "statusChanged"
        signalSpy.wait()

        if (status == Image.Null) {
            signalSpy.clear()
            signalSpy.wait()
        }

        if (status == Image.Loading) {
            signalSpy.clear()
            signalSpy.wait()
        }

        compare(status, Image.Ready, "Image not ready")
        console.log("Image loaded.")
    }

    function waitForAnimation() {
        signalSpy.signalName = "runningChanged"

        if (!running) {
            signalSpy.clear()
            signalSpy.wait()
            compare(running, true, "Animation did not start")
        }

        signalSpy.clear()
        console.log("Waiting for animation to finish...")
        signalSpy.wait()
        compare(running, false, "Animation did not stop within 5 seconds.")
    }

    function cleanupTest() {
        compare(running, false, "Animation is running after testcase")
        compare(crossFadeImage.__nextImage.source, "", "nextimage source is not reset")
    }

    function test_fadeFirst() {
        initTestFunction(true, true)

        loadImage("../../../graphics/phone_background.jpg")

        waitForAnimation()

        cleanupTest()
    }

    function test_no_fadeFirst() {
        initTestFunction(true, false)

        loadImage("../../../graphics/phone_background.jpg")

        cleanupTest()
    }

    function test_crossFade() {
        initTestFunction(true, false)

        loadImage("../../../graphics/phone_background.jpg")

        loadImage("../../../graphics/tablet_background.jpg")

        // Due to the internal implementation, __currentImage and __nextImage are swapped before the animation starts
        // Make sure z order reflects that too.
        compare(crossFadeImage.__currentImage.z > crossFadeImage.__nextImage.z, true, "new image should be above old image")
        compare(crossFadeImage.__currentImage.opacity < 0.5, true)
        compare(crossFadeImage.__nextImage.opacity > 0.5, true)

        waitForAnimation()

        compare(crossFadeImage.__currentImage.opacity > 0.5, true)
        compare(crossFadeImage.__nextImage.opacity < 0.5, true)

        cleanupTest()
    }
}
