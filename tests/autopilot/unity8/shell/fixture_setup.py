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

"""Set up and clean up fixtures for the Unity acceptance tests."""

import os
import subprocess
import sysconfig

import fixtures

import unity8


class FakeScopes(fixtures.Fixture):

    def setUp(self):
        super().setUp()
        self.useFixture(
            fixtures.EnvironmentVariable(
                'QML2_IMPORT_PATH',
                newvalue=self._get_fake_scopes_library_path()))

    def _get_fake_scopes_library_path(self):
        if unity8.running_installed_tests():
            mock_path = 'qml/scopefakes/'
        else:
            mock_path = os.path.join(
                '../lib/', sysconfig.get_config_var('MULTIARCH'),
                'unity8/qml/scopefakes/')
        lib_path = unity8.get_lib_path()
        ld_library_path = os.path.abspath(os.path.join(lib_path, mock_path))

        if not os.path.exists(ld_library_path):
            raise RuntimeError(
                'Expected library path does not exists: %s.' % (
                    ld_library_path))
        return ld_library_path


class Tutorial(fixtures.Fixture):

    def __init__(self, enable):
        super().__init__()
        self.enable = enable

    def setUp(self):
        super().setUp()
        original_state = self._is_tutorial_enabled()
        if self.enable != original_state:
            self.addCleanup(self._set_tutorial, original_state)
            self._set_tutorial(self.enable)

    def _is_tutorial_enabled(self):
        command = [
            'dbus-send', '--system', '--print-reply',
            '--dest=org.freedesktop.Accounts',
            '/org/freedesktop/Accounts/User32011',
            'org.freedesktop.DBus.Properties.Get',
            'string:com.canonical.unity.AccountsService',
            'string:demo-edges'
        ]
        output = subprocess.check_output(command, universal_newlines=True)
        return True if output.count('true') else False

    def _set_tutorial(self, value):
        value_string = 'true' if value else 'false'
        command = [
            'dbus-send', '--system', '--print-reply',
            '--dest=com.canonical.PropertyService',
            '/com/canonical/PropertyService',
            'com.canonical.PropertyService.SetProperty',
            'string:edge', 'boolean:{}'.format(value_string)
        ]
        subprocess.check_output(command)
