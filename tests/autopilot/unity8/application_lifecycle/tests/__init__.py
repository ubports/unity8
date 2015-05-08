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

from autopilot.matchers import Eventually
from testtools.matchers import Equals
from ubuntuuitoolkit import fixture_setup

from unity8 import process_helpers
from unity8.shell import tests


class ApplicationLifeCycleTestCase(tests.UnityTestCase):

    def setUp(self):
        super().setUp()
        self._qml_mock_enabled = False
        self._data_dirs_mock_enabled = False
        self.launch_unity()
        process_helpers.unlock_unity()

    def create_test_application(self):
        desktop_file_dict = fixture_setup.DEFAULT_DESKTOP_FILE_DICT
        desktop_file_dict.update({'X-Ubuntu-Single-Instance': 'true'})
        fake_application = fixture_setup.FakeApplication(
            desktop_file_dict=desktop_file_dict)
        self.useFixture(fake_application)
        return (
            fake_application.qml_file_path, fake_application.desktop_file_path)

    def assert_current_focused_application(self, application_name):
        self.assertThat(
            self.main_window.get_current_focused_app_id,
            Eventually(Equals(application_name)))
