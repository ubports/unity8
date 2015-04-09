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
    shell,
    fixture_setup,
    indicators,
    process_helpers
)
import os
from unity8.shell import tests
import ubuntuuitoolkit
import logging
from testtools.matchers import Equals, NotEquals
from autopilot.matchers import Eventually

logger = logging.getLogger(__name__)

class RotationBase(tests.UnityTestCase):
    """Base class for all shell-rotation tests that provides helper methods."""

    scenarios = tests._get_device_emulation_scenarios()

    def setUp(self):
        if model() == 'Desktop':
            self.skipTest('Test cannot be run on the desktop.')
        super(RotationBase, self).setUp()
        self._qml_mock_enabled = False
        self._data_dirs_mock_enabled = False

    def _assert_change_of_orientation_and_angle(self):
        tmp_o = self.shell_proxy.orientation
        tmp_a = self.shell_proxy.orientationAngle
        self.assertThat(self.orientation, Equals(tmp_o))
        self.assertThat(self.angle, Equals(tmp_a))

    def test_fake_sensor(self):
        unity_with_sensors = fixture_setup.LaunchUnityWithFakeSensors()
        self.useFixture(unity_with_sensors)
        process_helpers.unlock_unity(unity_with_sensors.unity_proxy)
        fake_sensors = unity_with_sensors.fake_sensors
        oriented_shell_proxy = unity_with_sensors.main_win.select_single('OrientedShell')

        fake_sensors.set_orientation_top_up()
        target_orientation = 1
        self.assertThat(oriented_shell_proxy.physicalOrientation, Eventually(Equals(target_orientation), timeout=15))

        fake_sensors.set_orientation_right_up()
        target_orientation = 8
        self.assertThat(oriented_shell_proxy.physicalOrientation, Eventually(Equals(target_orientation), timeout=15))

        fake_sensors.set_orientation_top_down()
        target_orientation = 4
        self.assertThat(oriented_shell_proxy.physicalOrientation, Eventually(Equals(target_orientation), timeout=15))

        fake_sensors.set_orientation_left_up()
        target_orientation = 2
        self.assertThat(oriented_shell_proxy.physicalOrientation, Eventually(Equals(target_orientation), timeout=15))

    def test_rotation_with_webbrowser_app(self):
        """Do an orientation-change and verify that an app and the shell adapted correctly"""

        unity_with_sensors = fixture_setup.LaunchUnityWithFakeSensors()
        self.useFixture(unity_with_sensors)
        process_helpers.unlock_unity(unity_with_sensors.unity_proxy)
        fake_sensors = unity_with_sensors.fake_sensors
        oriented_shell_proxy = unity_with_sensors.main_win.select_single('OrientedShell')
        self.shell_proxy = unity_with_sensors.main_win.select_single('Shell')

        # launch an application
        self.launch_upstart_application('webbrowser-app')
        unity_with_sensors.main_win.show_dash_from_launcher()
        unity_with_sensors.main_win.launch_application('webbrowser-app')
        self.assertThat(unity_with_sensors.main_win.get_current_focused_app_id(), Eventually(Equals('webbrowser-app')))

        # get default orientation and angle
        self.orientation = self.shell_proxy.orientation
        self.angle = self.shell_proxy.orientationAngle

        # check if fake sensors affect orientation and angle
        fake_sensors.set_orientation_top_up()
        self.orientation = 1
        self.angle = 0
        self.assertThat(oriented_shell_proxy.physicalOrientation, Eventually(Equals(self.orientation), timeout=15))
        if (self.orientation & oriented_shell_proxy.supportedOrientations):
            self._assert_change_of_orientation_and_angle()
        else:
            print("unsupported orientation TOP-UP. skipped.")

        fake_sensors.set_orientation_right_up()
        self.orientation = 8
        self.angle = 90
        self.assertThat(oriented_shell_proxy.physicalOrientation, Eventually(Equals(self.orientation), timeout=15))
        if (self.orientation & oriented_shell_proxy.supportedOrientations):
            self._assert_change_of_orientation_and_angle()
        else:
            print("unsupported orientation RIGHT-UP. skipped.")

        fake_sensors.set_orientation_top_down()
        self.orientation = 4
        self.angle = 180
        self.assertThat(oriented_shell_proxy.physicalOrientation, Eventually(Equals(self.orientation), timeout=15))
        if (self.orientation & oriented_shell_proxy.supportedOrientations):
            self._assert_change_of_orientation_and_angle()
        else:
            print("unsupported orientation TOP-DOWN. skipped.")

        fake_sensors.set_orientation_left_up()
        self.orientation = 2
        self.angle = 270
        self.assertThat(oriented_shell_proxy.physicalOrientation, Eventually(Equals(self.orientation), timeout=15))
        if (self.orientation & oriented_shell_proxy.supportedOrientations):
            self._assert_change_of_orientation_and_angle()
        else:
            print("unsupported orientation LEFT-UP. skipped.")
