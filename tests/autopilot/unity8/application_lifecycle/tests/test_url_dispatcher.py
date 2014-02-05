# -*- Mode: Python; coding: utf-8; indent-tabs-mode: nil; tab-width: 4 -*-
#
# Unity Autopilot Test Suite
# Copyright (C) 2014 Canonical
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

from autopilot import platform
from autopilot.matchers import Eventually
from testtools.matchers import Equals

from unity8 import process_helpers
from unity8.shell import tests


class URLDispatcherTestCase(tests.UnityTestCase):

    scenarios = tests._get_device_emulation_scenarios()

    def setUp(self):
        if platform.model() == 'Desktop':
            self.skipTest("URL dispatcher doesn't works on the desktop.")
        super(URLDispatcherTestCase, self).setUp()
        unity_proxy = self.launch_unity()
        process_helpers.unlock_unity(unity_proxy)

    def test_swipe_out_application_started_by_url_dispatcher(self):
        self.assertEqual('', self.main_window.get_current_focused_app_id())
        # XXX we shouldn't depend on external applictions; but the camera app
        # is already a depedency for other tests, so it's not that bad to use
        # it while the url-dispatcher implements the testability features to
        # let us launch a fake app. --elopio - 2014-02-05
        os.system('url-dispatcher application:///camera-app.desktop')
        self.assertThat(
            self.main_window.get_current_focused_app_id,
            Eventually(Equals('camera-app')))
        self.main_window.show_dash_swiping()
        self.assertThat(
            self.main_window.get_current_focused_app_id,
            Eventually(Equals('')))
