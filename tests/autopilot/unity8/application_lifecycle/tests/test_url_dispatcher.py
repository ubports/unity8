# -*- Mode: Python; coding: utf-8; indent-tabs-mode: nil; tab-width: 4 -*-
#
# Unity Autopilot Test Suite
# Copyright (C) 2014, 2015 Canonical
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

"""Test the integration with the URL dispatcher service."""

import os
import subprocess

from autopilot import platform

from unity8.application_lifecycle import tests


class URLDispatcherTestCase(tests.ApplicationLifeCycleTestCase):

    def setUp(self):
        if platform.model() == 'Desktop':
            self.skipTest("URL dispatcher doesn't work on the desktop.")
        super().setUp()

    def test_swipe_out_application_started_by_url_dispatcher(self):
        _, desktop_file_path = self.create_test_application()
        desktop_file_name = os.path.basename(desktop_file_path)
        application_name, _ = os.path.splitext(desktop_file_name)

        self.assertEqual(
            'unity8-dash', self.main_window.get_current_focused_app_id())
        self.addCleanup(os.system, 'pkill qmlscene')

        subprocess.check_call(
            ['url-dispatcher', 'application:///{}'.format(desktop_file_name)])
        self.assert_current_focused_application(application_name)

        self.main_window.show_dash_swiping()
        self.assert_current_focused_application('unity8-dash')
