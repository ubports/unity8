# -*- Mode: Python; coding: utf-8; indent-tabs-mode: nil; tab-width: 4 -*-
#
# Unity Autopilot Test Suite
# Copyright (C) 2015 Canonical
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

"""Set up and clean up fixtures for the Unity acceptance tests."""

import os
import subprocess

import fixtures


class IndicatorDisplayRotationLock(fixtures.Fixture):

    def __init__(self, enable):
        super().__init__()
        self.enable = enable

    def setUp(self):
        super().setUp()
        original_state = self._is_rotation_lock_enabled()
        if self.enable != original_state:
            self.addCleanup(self._set_rotation_lock, original_state)
            self._set_rotation_lock(self.enable)

    def _is_rotation_lock_enabled(self):
        command = [
            'gsettings', 'get',
            'com.ubuntu.touch.system',
            'rotation-lock'
        ]
        output = subprocess.check_output(command, universal_newlines=True)
        print (output)
        return True if output.count('true') else False

    def _set_rotation_lock(self, value):
        value_string = 'true' if value else 'false'
        command = [
            'gsettings', 'set',
            'com.ubuntu.touch.system',
            'rotation-lock', '{}'.format(value_string)
        ]
        subprocess.check_output(command)
