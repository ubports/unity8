# -*- Mode: Python; coding: utf-8; indent-tabs-mode: nil; tab-width: 4 -*-
#
# Unity Autopilot Test Suite
# Copyright (C) 2012-2013 Canonical
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

from unity8.shell.tests import UnityTestCase, _get_device_emulation_scenarios
from autopilot.introspection.types import Rectangle
from testtools.matchers import Equals

class TestGreeter(UnityTestCase):

    """Tests the Shell Greeter."""

    scenarios = _get_device_emulation_scenarios()

    def test_greeter_background(self):
        """Test that the background of the greeter is placed correctly

        """
        self.launch_greeter()
        greeter_background = self.main_window.get_greeter_background()
        winRect = Rectangle(self.main_window.x, self.main_window.y,
                            self.main_window.width, self.main_window.height)
        self.assertThat(greeter_background.globalRect, Equals(winRect))
