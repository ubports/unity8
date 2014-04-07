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

from autopilot.matchers import Eventually
from autopilot.platform import model
from testtools.matchers import Equals
from ubuntuuitoolkit import (
    base,
    emulators as toolkit_emulators,
)

from unity8.application_lifecycle import tests
from unity8.process_helpers import unlock_unity
from unity8.shell import disable_qml_mocking
from unity8.shell.tests import _get_device_emulation_scenarios


logger = logging.getLogger(__name__)


class ApplicationLifecycleTests(tests.ApplicationLifeCycleTestCase):

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

    def _launch_app(self, app_name):
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

    def launch_fake_app(self):
        qml_file_path, desktop_file_path = self.create_test_application()
        desktop_file_name = os.path.basename(desktop_file_path)
        application_name, _ = os.path.splitext(desktop_file_name)
        self.launch_test_application(
            base.get_qmlscene_launch_command(),
            qml_file_path,
            '--desktop_file_hint={0}'.format(
                desktop_file_path),
                emulator_base=toolkit_emulators.UbuntuUIToolkitEmulatorBase,
                app_type='qt')
        return application_name

    @disable_qml_mocking
    def test_can_launch_application(self):
        """Must be able to launch an application."""
        unity_proxy = self.launch_unity()
        unlock_unity(unity_proxy)

        application_name = self.launch_fake_app()
        self.assert_current_focused_application(application_name)

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

        self._launch_app("address-book-app")
        self.assertThat(
            self.main_window.get_current_focused_app_id(),
            Eventually(Equals("address-book-app"))
        )

        self.swipe_screen_from_right()

        self.assertThat(
            self.main_window.get_current_focused_app_id(),
            Eventually(Equals("messaging-app"))
        )
