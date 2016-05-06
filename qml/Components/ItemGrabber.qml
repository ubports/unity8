/*
 * Copyright (C) 2014-2016 Canonical, Ltd.
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

import QtQuick 2.4
import ScreenshotDirectory 0.1

/*
    Captures an image of the given item and saves it in a screenshots directory.
    It also displays a flash visual effect and camera shutter sound, as feedback
    to the user to hint that a screenshot was taken.
 */
Rectangle {
    id: root
    visible: false
    color: "white"
    opacity: 0.0

    ScreenshotDirectory {
        id: screenshotDirectory
        objectName: "screenGrabber"
    }

    NotificationAudio {
        id: shutterSound
        source: "/system/media/audio/ui/camera_click.ogg"
    }

    function capture(item) {
        d.target = item;
        visible = true;
        shutterSound.stop();
        shutterSound.play();
        fadeIn.start();
    }

    NumberAnimation on opacity {
        id: fadeIn
        from: 0.0
        to: 1.0
        onStopped: {
            if (visible) {
                fadeOut.start();
            }
        }
    }

    QtObject {
        id: d
        property Item target
    }

    NumberAnimation on opacity {
        id: fadeOut
        from: 1.0
        to: 0.0
        onStopped: {
            if (visible) {
                d.target.grabToImage(function(result)
                    {
                        var fileName = screenshotDirectory.makeFileName();
                        if (fileName.length === 0) {
                            console.warn("ItemGrabber: No fileName to save image to");
                        } else {
                            console.log("ItemGrabber: Saving image to " + fileName);
                            result.saveToFile(fileName);
                        }
                    });

                visible = false;
            }
        }
    }
}
