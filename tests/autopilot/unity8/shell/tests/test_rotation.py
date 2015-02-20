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

logger = logging.getLogger(__name__)

class RotationBase(tests.UnityTestCase):
    """Base class for all shell-rotation tests that provides helper methods."""

    scenarios = tests._get_device_emulation_scenarios()

    def setUp(self):
        if model() == 'Desktop':
            self.skipTest('Test cannot be run on the desktop.')
        super(RotationBase, self).setUp()

    def launch_fake_app(self):
        desktop_file_dict = ubuntuuitoolkit.fixture_setup.DEFAULT_DESKTOP_FILE_DICT
        desktop_file_dict.update({'X-Ubuntu-Single-Instance': 'true'})
        fake_application = ubuntuuitoolkit.fixture_setup.FakeApplication(
            desktop_file_dict=desktop_file_dict)
        self.useFixture(fake_application)        
        _ = fake_application.qml_file_path
        desktop_file_path = fake_application.desktop_file_path
        desktop_file_name = os.path.basename(desktop_file_path)
        application_name, _ = os.path.splitext(desktop_file_name)
        self.launch_upstart_application(application_name)
        return application_name

    def test_rotation(self):
        """Do an orientation-change and verify that an app and the shell adapted correctly"""

        # get unity8 with fake sensors running 
        unity_with_sensors = fixture_setup.LaunchUnityWithFakeSensors()
        self.useFixture(unity_with_sensors)
        process_helpers.unlock_unity(unity_with_sensors.unity_proxy)
        self.fake_sensors = unity_with_sensors.fake_sensors

        # launch an application
        app_name = self.launch_fake_app()

        #check for nativeOrientation
        print ("default...")
        print ("# of children: ", len(unity_with_sensors.main_win.get_children()))
        print ("properties: ", unity_with_sensors.main_win.get_properties())
        print ("shell: ", unity_with_sensors.get_shell())
        #print ("orientation-angle: ", unity_with_sensors.main_win.get_shell_orientation_angle())
        #print ("orientation: ", self.main_window.get_shell_orientation())
        #print ("prim. orientation: ", self.main_window.get_shell_primary_orientation())
        #print ("native orientation: ", self.main_window.get_shell_native_orientation())
        self.fake_sensors.set_orientation_top_up()
        #print ("after set_orientation_top_up...")
        #print ("orientation-angle: ", self.main_window.get_shell_orientation_angle())
        #print ("orientation: ", self.main_window.get_shell_orientation())
        #print ("prim. orientation: ", self.main_window.get_shell_primary_orientation())
        #print ("native orientation: ", self.main_window.get_shell_native_orientation())

	# set accelerometer sensor rotation from 0 to 90
        #self.fake_sensors.set_orientation_right_up()
        #print ("after set_orientation_right_up...")
        #print ("orientation-angle: ", self.main_window.get_shell_orientation_angle())
        #print ("orientation: ", self.main_window.get_shell_orientation())
        #print ("prim. orientation: ", self.main_window.get_shell_primary_orientation())
        #print ("native orientation: ", self.main_window.get_shell_native_orientation())

        # check that unity8 rotated its UI form 0 (portrait aspect ratio) to 90 (landscape aspect ratio)

        # check that the application got resized from a portrait aspect ratio to a landscape aspect ratio
