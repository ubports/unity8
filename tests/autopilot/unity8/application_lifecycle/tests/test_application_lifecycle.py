# -*- Mode: Python; coding: utf-8; indent-tabs-mode: nil; tab-width: 4 -*-
#
# Unity Autopilot Test Suite
# Copyright (C) 2013, 2014 Canonical
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

from __future__ import absolute_import

import logging
import os

from autopilot.platform import model

from unity8.application_lifecycle import tests


logger = logging.getLogger(__name__)


class ApplicationLifecycleTests(tests.ApplicationLifeCycleTestCase):

    def setUp(self):
        if model() == 'Desktop':
            self.skipTest('Test cannot be run on the desktop.')
        super(ApplicationLifecycleTests, self).setUp()
        self.launch_unity()

    def swipe_screen_from_right(self):
        width = self.main_window.width
        height = self.main_window.height
        start_x = width
        start_y = int(height/2)
        end_x = int(width/2)
        end_y = start_y

        logger.info("Swiping screen from the right edge")
        self.touch.drag(start_x, start_y, end_x, end_y)

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
