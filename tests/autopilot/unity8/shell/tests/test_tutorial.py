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

from unity8.shell import (
    fixture_setup,
    tests
)
# unused import to load the tutorial emulators custom proxy objects.
from unity8.shell.emulators import tutorial  # NOQA


class TutorialTestCase(tests.UnityTestCase):

    def setUp(self):
        super(TutorialTestCase, self).setUp()
        self._qml_mock_enabled = False
        self._data_dirs_mock_enabled = False
        self._lightdm_mock_type = False

        self.useFixture(fixture_setup.Tutorial(True))
        self.unity = self.launch_unity()

    def test_complete_tutorial(self):
        greeter = self.main_window.get_greeter()
        tutorial = self.unity.select_single('Tutorial')
        self.assertThat(tutorial.running, Eventually(Equals(True)))
        greeter.swipe()
        page = self.unity.wait_select_single(objectName='tutorialLeft')
        page.short_swipe_right()
        page = self.unity.wait_select_single(objectName='tutorialLeftFinish')
        page.tap()
        page = self.unity.wait_select_single(objectName='tutorialRight')
        page.swipe_left()
        page.tap()
        page = self.unity.wait_select_single(objectName='tutorialBottom')
        page.swipe_up()
        page = self.unity.wait_select_single(objectName='tutorialBottomFinish')
        page.tap()
        self.assertThat(tutorial.running, Eventually(Equals(False)))
