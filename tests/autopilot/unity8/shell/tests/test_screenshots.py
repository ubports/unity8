# -*- Mode: Python; coding: utf-8; indent-tabs-mode: nil; tab-width: 4 -*-
#
# Unity Autopilot Test Suite
# Copyright (C) 2014 Canonical
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>.
#

import evdev
import os
import time

from gi.repository import Notify
from testtools.matchers import Equals

from unity8.shell import (
    fixture_setup,
    tests
)

from unity8.process_helpers import unlock_unity

class ScreenShotTestCase(tests.UnityTestCase):

    AP_SCREENSHOT_DIR = '/home/phablet/Pictures/Screenshots'
    SCREENSHOT_DELAY_SECS = 2

    def setUp(self):
        super(ScreenShotTestCase, self).setUp()
        unity_proxy = self.launch_unity()
        unlock_unity(unity_proxy)

    def test_volume_is_hidden(self):
        uinput = evdev.UInput(name='apinput', devnode='/dev/autopilot-uinput')
        uinput.write(evdev.ecodes.EV_KEY, evdev.ecodes.KEY_VOLUMEDOWN, 1)
        uinput.write(evdev.ecodes.EV_KEY, evdev.ecodes.KEY_VOLUMEDOWN, 0)
        uinput.syn()
        a=self.main_window.select_single("Notification", objectName="notification1")
        print (a.icon)

    def test_take_screenshot(self):
        num_screenshots_pre = len(os.listdir(self.AP_SCREENSHOT_DIR))
        self._take_screenshot()
        num_screenshots_post = len(os.listdir(self.AP_SCREENSHOT_DIR))
        self.assertThat(num_screenshots_pre + 1, Equals(num_screenshots_post))

    def _take_screenshot(self):
        uinput = evdev.UInput(name='apinput', devnode='/dev/autopilot-uinput')
        uinput.write(evdev.ecodes.EV_KEY, evdev.ecodes.KEY_POWER, 1)
        uinput.write(evdev.ecodes.EV_KEY, evdev.ecodes.KEY_VOLUMEDOWN, 1)
        uinput.syn()

        time.sleep(self.SCREENSHOT_DELAY_SECS)

        uinput.write(evdev.ecodes.EV_KEY, evdev.ecodes.KEY_POWER, 0)
        uinput.write(evdev.ecodes.EV_KEY, evdev.ecodes.KEY_VOLUMEDOWN, 0)
        uinput.syn()

