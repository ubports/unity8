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

"""Tests for the application lifecycle in the greeter."""

from __future__ import absolute_import

import logging
import os
import subprocess

from autopilot.matchers import Eventually
from autopilot.platform import model
from testtools.matchers import Equals

from unity8.application_lifecycle import tests
from unity8.shell import with_lightdm_mock


logger = logging.getLogger(__name__)


class GreeterApplicationLifecycleTests(tests.ApplicationLifeCycleTestCase):

    def setUp(self):
        if model() == 'Desktop':
            self.skipTest('Test cannot be run on the desktop.')
        super(GreeterApplicationLifecycleTests, self).setUp()
        self.launch_greeter()

    @with_lightdm_mock("single")
    def test_greeter_hides_on_url_dispatcher(self):
        """Greeter should hide when an app is opened"""
        greeter = self.main_window.get_greeter()
        self.assertThat(greeter.created, Eventually(Equals(True)))

        _, desktop_file_path = self.create_test_application()
        desktop_file_name = os.path.basename(desktop_file_path)
        application_name, _ = os.path.splitext(desktop_file_name)

        subprocess.check_call(
            ['url-dispatcher', 'application:///{}'.format(desktop_file_name)])
        self.assertThat(greeter.created, Eventually(Equals(False)))
