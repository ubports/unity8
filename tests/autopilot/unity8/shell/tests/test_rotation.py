# -*- Mode: Python; coding: utf-8; indent-tabs-mode: nil; tab-width: 4 -*-
#
# Unity Autopilot Test Suite
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
#

"""Tests for shell-rotation"""

from autopilot.platform import model
from unity8 import (
    fixture_setup,
    process_helpers
)
from unity8.shell import tests
import logging
from testtools.matchers import Equals
from autopilot.matchers import Eventually

logger = logging.getLogger(__name__)


class RotationBase(tests.UnityTestCase):
    """Base class for all shell-rotation tests that provides helper methods."""

    def setUp(self):
        if model() == 'Desktop':
            self.skipTest('Test cannot be run on the desktop.')
        super().setUp()
        self._qml_mock_enabled = False
        self._data_dirs_mock_enabled = False

    def _assert_change_of_orientation_and_angle(self):
        self.assertThat(self.shell_proxy.orientation,
                        Eventually(Equals(self.orientation)))
        self.assertThat(self.shell_proxy.orientationAngle,
                        Eventually(Equals(self.angle)))


class TestFakeSensor(RotationBase):
    scenarios = [('top up', {'action': 'top_up', 'orientation': 1}),
                 ('right up', {'action': 'right_up', 'orientation': 8}),
                 ('top down', {'action': 'top_down', 'orientation': 4}),
                 ('left up', {'action': 'left_up', 'orientation': 2})]

    def test_fake_sensor(self):
        unity_with_sensors = fixture_setup.LaunchUnityWithFakeSensors()
        self.useFixture(unity_with_sensors)
        process_helpers.unlock_unity()
        fake_sensors = unity_with_sensors.fake_sensors
        o_proxy = unity_with_sensors.main_win.select_single('OrientedShell')

        fake_sensors.set_orientation(self.action)
        self.assertThat(o_proxy.physicalOrientation,
                        Eventually(Equals(self.orientation), timeout=15))


class TestRotationWithApp(RotationBase):
    scenarios = [
        ('top up, angle 0',
            {'action': 'top_up', 'orientation': 1, 'angle': 0}),
        ('right up, angle 90',
            {'action': 'right_up', 'orientation': 8, 'angle': 90}),
        ('top down, angle 180',
            {'action': 'top_down', 'orientation': 4, 'angle': 180}),
        ('left up, angle 270',
            {'action': 'left_up', 'orientation': 2, 'angle': 270})]

    def test_rotation_with_webbrowser_app(self):
        """Do an orientation-change and verify that an app and the shell
        adapted correctly"""

        unity_with_sensors = fixture_setup.LaunchUnityWithFakeSensors()
        self.useFixture(unity_with_sensors)
        process_helpers.unlock_unity()
        fake_sensors = unity_with_sensors.fake_sensors
        o_proxy = unity_with_sensors.main_win.select_single('OrientedShell')
        self.shell_proxy = unity_with_sensors.main_win.select_single('Shell')

        # launch an application
        self.launch_upstart_application('morph-browser')
        unity_with_sensors.main_win.show_dash_from_launcher()
        unity_with_sensors.main_win.launch_application('morph-browser')

        # skip test early, if device doesn't support a certain orientation
        if not (self.shell_proxy.orientation & o_proxy.supportedOrientations):
            self.skipTest('unsupported orientation ' + self.action)

        self.assertThat(
            unity_with_sensors.main_win.get_current_focused_app_id(),
            Eventually(Equals('morph-browser')))

        # get default orientation and angle
        self.orientation = self.shell_proxy.orientation
        self.angle = self.shell_proxy.orientationAngle

        # check if fake sensors affect orientation and angle
        fake_sensors.set_orientation(self.action)
        self.assertThat(o_proxy.physicalOrientation,
                        Eventually(Equals(self.orientation), timeout=15))
        self._assert_change_of_orientation_and_angle()
