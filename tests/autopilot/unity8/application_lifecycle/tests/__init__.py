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

from autopilot.matchers import Eventually
from testtools.matchers import Equals
from ubuntuuitoolkit import fixture_setup

from unity8.shell import tests


class ApplicationLifeCycleTestCase(tests.UnityTestCase):

    def create_test_application(self, test_qml=None):
        fake_application = fixture_setup.FakeApplication(test_qml)
        self.useFixture(fake_application)
        return (
            fake_application.qml_file_path, fake_application.desktop_file_path)

    def assert_current_focused_application(self, application_name):
        self.assertThat(
            self.main_window.get_current_focused_app_id,
            Eventually(Equals(application_name)))
