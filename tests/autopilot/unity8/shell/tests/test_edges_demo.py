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
# unused import to load the edge emulators custom proxy objects.
from unity8.shell.emulators import edges_demo  # NOQA


class EdgesDemoTestCase(tests.UnityTestCase):

    def setUp(self):
        super().setUp()
        self._qml_mock_enabled = False
        self._data_dirs_mock_enabled = False
        self._lightdm_mock_type = False

        self.useFixture(fixture_setup.EdgesDemo(True))
        self.unity = self.launch_unity()

    def test_complete_edge_demo(self):
        edge_demo = self.unity.select_single('EdgeDemo')
        self.assertThat(edge_demo.running, Eventually(Equals(True)))
        right_edge_overlay = self.unity.wait_select_single(
            edge='right', active=True)
        top_edge_overlay = right_edge_overlay.swipe()
        bottom_edge_overlay = top_edge_overlay.swipe()
        left_edge_overlay = bottom_edge_overlay.swipe()
        final_overlay = left_edge_overlay.swipe()
        final_overlay.tap_to_start()
        self.assertThat(edge_demo.running, Eventually(Equals(False)))
