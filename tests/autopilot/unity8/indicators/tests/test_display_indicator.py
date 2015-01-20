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
    indicators,
)
from unity8.shell import tests


class DisplayIndicatorTestCase(tests.IndicatorTestCase):

    def test(self):
        display_indicator = indicators.DisplayIndicator(self.main_window)
        display_indicator_page = display_indicator.open()
        fixture = fixture_setup.DisplayRotationLock(False)

        display_indicator_page.unlock_rotation()
        self.assertEqual(fixture._is_rotation_lock_enabled(), False)

        display_indicator_page.lock_rotation()
        self.assertEqual(fixture._is_rotation_lock_enabled(), True)
