# -*- Mode: Python; coding: utf-8; indent-tabs-mode: nil; tab-width: 4 -*-
#
# Unity Autopilot Test Suite
# Copyright (C) 2013 Canonical
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

from autopilot.matchers import Eventually
from autopilot.platform import model

import logging

from testtools.matchers import Equals, NotEquals
from unity8.shell.tests import UnityTestCase, _get_device_emulation_scenarios

logger = logging.getLogger(__name__)


class ApplicationLifecycleTests(UnityTestCase):

    scenarios = _get_device_emulation_scenarios()

    def setUp(self):
        super(ApplicationLifecycleTests, self).setUp()
        if model() == "Desktop":
            self.skipTest("Test must be run on a device.")

    def swipe_from_right(self):
        qml_view = self.main_window.get_qml_view()
        width = qml_view.width
        height = qml_view.height
        start_x = width
        start_y = int(height/2)
        end_x = int(width/2)
        end_y = start_y

        self.touch.drag(start_x, start_y, end_x, end_y)

    def test_can_launch_application(self):
        """must be able to launch and interact with an application."""
        unity = self.launch_unity()
        self.main_window.get_greeter().swipe()

        app = self.launch_test_application(
            "messaging-app",
            "--desktop_file_hint="
            "/usr/share/applications/messaging-app.desktop",
            "--stage_hint=main_stage",
            app_type='qt'
        )
        shell = unity.select_single("Shell")

        self.assertThat(app, NotEquals(None))
        self.assertThat(shell.currentFocusedAppId, Equals("messaging-app"))

    def test_can_launch_multiple_applications(self):
        """A second application launched must be usable."""
        unity = self.launch_unity()
        self.main_window.get_greeter().swipe()

        first_app = self.launch_test_application(
            "messaging-app",
            "--desktop_file_hint="
            "/usr/share/applications/messaging-app.desktop",
            "--stage_hint=main_stage",
            app_type='qt'
        )

        second_app = self.launch_test_application(
            "address-book-app",
            "--desktop_file_hint="
            "/usr/share/applications/address-book-app.desktop",
            "--stage_hint=main_stage",
            app_type='qt'
        )

        shell = unity.select_single("Shell")

        # Required?
        self.assertThat(shell.currentFocusedAppId, NotEquals("messaging-app"))
        self.assertThat(shell.currentFocusedAppId, Equals("address-book-app"))

    def test_app_moves_from_unfocused_to_focused(self):
        """An application that is in the unfocused state must be able to be
        brought back to the focused state.

        """
        unity = self.launch_unity()
        self.main_window.get_greeter().swipe()

        first_app = self.launch_test_application(
            "messaging-app",
            "--desktop_file_hint="
            "/usr/share/applications/messaging-app.desktop",
            "--stage_hint=main_stage",
            app_type='qt'
        )

        second_app = self.launch_test_application(
            "address-book-app",
            "--desktop_file_hint="
            "/usr/share/applications/address-book-app.desktop",
            "--stage_hint=main_stage",
            app_type='qt'
        )

        self.swipe_from_right()

        shell = unity.select_single("Shell")
        self.assertThat(
            shell.currentFocusedAppId,
            Eventually(Equals("messaging-app"))
        )
