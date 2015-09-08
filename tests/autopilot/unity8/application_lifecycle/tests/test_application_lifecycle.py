# -*- Mode: Python; coding: utf-8; indent-tabs-mode: nil; tab-width: 4 -*-
#
# Unity Autopilot Test Suite
# Copyright (C) 2013, 2014, 2015 Canonical
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

"""Tests for the application lifecycle."""

import logging
import os
import threading

from autopilot.platform import model
from autopilot.application import _launcher

from unity8 import process_helpers
from unity8.application_lifecycle import tests


logger = logging.getLogger(__name__)


class ApplicationLifecycleTests(tests.ApplicationLifeCycleTestCase):

    def setUp(self):
        if model() == 'Desktop':
            self.skipTest('Test cannot be run on the desktop.')
        super().setUp()

    def swipe_screen_from_right(self):
        width = self.main_window.width
        height = self.main_window.height
        start_x = width
        start_y = int(height/2)
        end_x = int(width*3/4)
        end_y = start_y

        logger.info("Swiping screen from the right edge")
        self.main_window.pointing_device.drag(start_x, start_y, end_x, end_y)

    def launch_fake_app(self):
        _, desktop_file_path = self.create_test_application()
        desktop_file_name = os.path.basename(desktop_file_path)
        application_name, _ = os.path.splitext(desktop_file_name)
        self.launch_upstart_application(application_name)
        return application_name

    def test_can_launch_application(self):
        """Must be able to launch an application."""
        application_name = self.launch_fake_app()
        self.assert_current_focused_application(application_name)

    def test_can_launch_multiple_applications(self):
        """A second application launched must be focused."""
        application1_name = self.launch_fake_app()
        self.assert_current_focused_application(application1_name)

        application2_name = self.launch_fake_app()
        self.assertFalse(application1_name == application2_name)
        self.assert_current_focused_application(application2_name)

    def test_app_moves_from_unfocused_to_focused(self):
        """An application that is in the unfocused state must be able to be
        brought back to the focused state.

        """
        application1_name = self.launch_fake_app()
        self.assert_current_focused_application(application1_name)

        application2_name = self.launch_fake_app()
        self.assertFalse(application1_name == application2_name)
        self.assert_current_focused_application(application2_name)

        self.swipe_screen_from_right()

        self.assert_current_focused_application(application1_name)

    def test_greeter_hides_on_app_open(self):
        """Greeter should hide when an app is opened"""
        process_helpers.lock_unity()

        # FIXME - this is because the device greeter uses a password.
        # Need to be able to selectively enable mocks so that we can use the
        # fake greeter.
        def unlock_thread_worker(greeter):
            greeter.wait_swiped_away()
            process_helpers.unlock_unity()
            greeter.created.wait_for(False)

        greeter = self.main_window.get_greeter()
        unlock_thread = threading.Thread(
            target=unlock_thread_worker, args=(greeter,))
        unlock_thread.start()
        application_name = self.launch_fake_app()
        unlock_thread.join(10)

        self.assert_current_focused_application(application_name)

    def test_greeter_hides_on_app_focus(self):
        """Greeter should hide when an app is re-focused"""
        application_name = self.launch_fake_app()
        self.assert_current_focused_application(application_name)

        self.main_window.show_dash_swiping()
        self.assert_current_focused_application('unity8-dash')

        process_helpers.lock_unity()

        self.launch_upstart_application(application_name, [], _launcher.AlreadyLaunchedUpstartLauncher)
        greeter = self.main_window.get_greeter()
        greeter.wait_swiped_away()
        process_helpers.unlock_unity()
        self.assert_current_focused_application(application_name)

    def test_click_dash_icon_must_unfocus_application(self):
        application_name = self.launch_fake_app()
        self.assert_current_focused_application(application_name)

        self.main_window.show_dash_from_launcher()

        self.assert_current_focused_application('unity8-dash')

    def test_click_app_icon_on_dash_must_focus_it(self):
        application_name = self.launch_fake_app()
        self.main_window.show_dash_from_launcher()

        self.main_window.launch_application(application_name)
        self.assert_current_focused_application(application_name)
