/*
 * Copyright (C) 2014-2015 Canonical, Ltd.
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
import "../../../qml/Components"

TestCase {
    name: "PhysicalKeysMapper"

    Loader {
        // Using a Loader here to make sure mapper state is coherent
        // regardless of unmatched KeyPress and KeyRelease events
        id: loader
        active: false
        sourceComponent: PhysicalKeysMapper { }
    }

    SignalSpy {
        id: powerSpy
        target: loader.item
        signalName: "powerKeyLongPressed"
    }

    SignalSpy {
        id: volumeDownSpy
        target: loader.item
        signalName: "volumeDownTriggered"
    }

    SignalSpy {
        id: volumeUpSpy
        target: loader.item
        signalName: "volumeUpTriggered"
    }

    SignalSpy {
        id: screenshotSpy
        target: loader.item
        signalName: "screenshotTriggered"
    }

    function init() {
        loader.active = true;
        tryCompare(loader.status == Loader.Ready);
    }

    function cleanup() {
        loader.active = false;
        powerSpy.clear();
        volumeDownSpy.clear();
        volumeUpSpy.clear();
        screenshotSpy.clear();
    }

    function test_LongPressPowerButton() {
        loader.item.onKeyPressed({ key: Qt.Key_PowerDown });

        expectFailContinue("", "Power signal should not be emitted within a second");
        powerSpy.wait(1000);
        powerSpy.clear();

        loader.item.onKeyPressed({ key: Qt.Key_PowerDown, isAutoRepeat: true });
        powerSpy.wait(1500);
    }

    function test_ScreenshotButtons_data() {
        return [
            { tag: "UpFirst", first: Qt.Key_VolumeUp, second: Qt.Key_VolumeDown },
            { tag: "DownFirst", first: Qt.Key_VolumeDown, second: Qt.Key_VolumeUp },
        ];
    }

    function test_ScreenshotButtons(data) {
        loader.item.onKeyPressed({ key: data.first });
        loader.item.onKeyPressed({ key: data.second });
        screenshotSpy.wait();
        loader.item.onKeyReleased({ key: data.first });
        loader.item.onKeyReleased({ key: data.second });
        expectFailContinue("", "VolumeUp signal should not fire");
        volumeUpSpy.wait(100);
        expectFailContinue("", "VolumeDown signal should not fire");
        volumeDownSpy.wait(100);
    }

    function test_VolumeButton_data() {
        return [
            { tag: "Down", key: Qt.Key_VolumeDown, spy: volumeDownSpy },
            { tag: "Up", key: Qt.Key_VolumeUp, spy: volumeUpSpy },
        ];
    }

    function test_VolumeButton(data) {
        loader.item.onKeyPressed({ key: data.key });
        expectFailContinue("", "Signal should not fire on press");
        data.spy.wait(100);
        data.spy.clear();

        loader.item.onKeyReleased({ key: data.key });
        data.spy.wait();

        loader.item.onKeyPressed({ key: data.key });
        loader.item.onKeyPressed({ key: data.key, isAutoRepeat: true });
        data.spy.wait();
    }
}
