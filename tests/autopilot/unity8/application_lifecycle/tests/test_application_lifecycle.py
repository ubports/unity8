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

from unity8.process_helpers import lock_unity, unlock_unity
from unity8.shell import disable_qml_mocking
from unity8.shell.tests import UnityTestCase, _get_device_emulation_scenarios

from autopilot.matchers import Eventually
from autopilot.platform import model
from testtools.matchers import Equals, NotEquals

import logging
import subprocess

logger = logging.getLogger(__name__)


class ApplicationLifecycleTests(UnityTestCase):

    scenarios = _get_device_emulation_scenarios()

    def setUp(self):
        super(ApplicationLifecycleTests, self).setUp()
        if model() == "Desktop":
            self.skipTest("Test cannot be run on the desktop.")

    def swipe_screen_from_right(self):
        width = self.main_window.width
        height = self.main_window.height
        start_x = width
        start_y = int(height/2)
        end_x = int(width/2)
        end_y = start_y

        logger.info("Swiping screen from the right edge")
        self.touch.drag(start_x, start_y, end_x, end_y)

    def swipe_screen_from_left(self):
        width = self.main_window.width
        height = self.main_window.height
        start_x = 0
        start_y = int(height/2)
        end_x = width
        end_y = start_y

        logger.info("Swiping screen from the left edge")
        self.touch.drag(start_x, start_y, end_x, end_y)

    def _launch_app_directly(self, app_name):
        """Launches the application *app_name*

        Assumes that the desktop file resides at:
        /usr/share/applications/{app_name}.desktop

        """
        desktop_file = "--desktop_file_hint="\
            "/usr/share/applications/{app_name}.desktop".format(
                app_name=app_name
            )
        return self.launch_test_application(
            app_name,
            desktop_file,
            "--stage_hint=main_stage",
            app_type='qt'
        )

    def _launch_app(self, app_name):
        """Launches the application *app_name* via upstart."""
        command = ['initctl', '--quiet', 'start', 'application',
                   'APP_ID=%s' % app_name]
        subprocess.check_call(command)

        command = ['pkill', '-f', '-9', app_name]
        self.addCleanup(subprocess.call, command)

    @disable_qml_mocking
    def test_can_launch_application(self):
        """Must be able to launch an application."""
        unity_proxy = self.launch_unity()
        unlock_unity(unity_proxy)

        self._launch_app("messaging-app")
        self.assertThat(
            self.main_window.get_current_focused_app_id(),
            Eventually(Equals("messaging-app"))
        )

    @disable_qml_mocking
    def test_can_launch_multiple_applications(self):
        """A second application launched must be focused."""
        unity_proxy = self.launch_unity()
        unlock_unity(unity_proxy)

        self._launch_app("messaging-app")
        self.assertThat(
            self.main_window.get_current_focused_app_id(),
            Eventually(Equals("messaging-app"))
        )

        self._launch_app("address-book-app")
        self.assertThat(
            self.main_window.get_current_focused_app_id(),
            Eventually(Equals("address-book-app"))
        )

    @disable_qml_mocking
    def test_app_moves_from_unfocused_to_focused(self):
        """An application that is in the unfocused state must be able to be
        brought back to the focused state.

        """
        unity_proxy = self.launch_unity()
        unlock_unity(unity_proxy)

        self._launch_app("messaging-app")
        self.assertThat(
            self.main_window.get_current_focused_app_id(),
            Eventually(Equals("messaging-app"))
        )

        # FIXME: this should be able to launch via upstart.  Bug #1273844
        self._launch_app_directly("address-book-app")
        self.assertThat(
            self.main_window.get_current_focused_app_id(),
            Eventually(Equals("address-book-app"))
        )

        self.swipe_screen_from_right()

        self.assertThat(
            self.main_window.get_current_focused_app_id(),
            Eventually(Equals("messaging-app"))
        )

    @disable_qml_mocking
    def test_greeter_hides_on_app_open(self):
        """Greeter should hide when an app is opened"""
        unity_proxy = self.launch_unity()
        greeter = self.main_window.get_greeter()
        self.assertThat(greeter.created, Eventually(Equals(True)))

        self._launch_app("messaging-app")
        self.assertThat(greeter.created, Eventually(Equals(False)))
        self.assertThat(
            self.main_window.get_current_focused_app_id(),
            Eventually(Equals("messaging-app"))
        )

    @disable_qml_mocking
    def test_greeter_hides_on_app_focus(self):
        """Greeter should hide when an app is re-focused"""
        unity_proxy = self.launch_unity()
        greeter = self.main_window.get_greeter()
        unlock_unity(unity_proxy)

        self._launch_app("messaging-app")
        self.assertThat(
            self.main_window.get_current_focused_app_id(),
            Eventually(Equals("messaging-app"))
        )

        self.swipe_screen_from_left()
        self.assertThat(
            self.main_window.get_current_focused_app_id(),
            Eventually(Equals(''))
        )

        lock_unity()
        self.assertThat(greeter.created, Eventually(Equals(True)))

        self._launch_app("messaging-app")
        self.assertThat(greeter.created, Eventually(Equals(False)))
        self.assertThat(
            self.main_window.get_current_focused_app_id(),
            Eventually(Equals("messaging-app"))
        )
