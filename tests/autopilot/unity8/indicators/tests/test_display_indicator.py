# -*- Mode: Python; coding: utf-8; indent-tabs-mode: nil; tab-width: 4 -*-
#
# Unity Indicators Autopilot Test Suite
# Copyright (C) 2015 Canonical
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

from unity8 import (
    fixture_setup,
    indicators
)
from unity8.indicators import tests


class DisplayIndicatorTestCase(tests.DeviceIndicatorTestCase):

    scenarios = tests.IndicatorTestCase.device_emulation_scenarios

    def test_indicator_icon_must_be_visible_after_rotation_locked(self):
        rotation_unlocked = fixture_setup.DisplayRotationLock(False)
        self.useFixture(rotation_unlocked)
        display_indicator = indicators.DisplayIndicator(self.main_window)
        self.assertFalse(display_indicator.is_indicator_icon_visible())

        display_indicator_page = display_indicator.open()
        display_indicator_page.lock_rotation()
        display_indicator.close()

        self.assertTrue(display_indicator.is_indicator_icon_visible())

    def test_indicator_icon_must_not_be_visible_after_rotation_unlocked(self):
        rotation_locked = fixture_setup.DisplayRotationLock(True)
        self.useFixture(rotation_locked)
        display_indicator = indicators.DisplayIndicator(self.main_window)
        self.assertTrue(display_indicator.is_indicator_icon_visible())

        display_indicator_page = display_indicator.open()
        display_indicator_page.unlock_rotation()
        display_indicator.close()

        self.assertFalse(display_indicator.is_indicator_icon_visible())
