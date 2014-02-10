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

"""Set up and clean up fixtures for the Unity acceptance tests."""

import os
import sysconfig

import fixtures

import unity8


class FakeScopes(fixtures.Fixture):

    def setUp(self):
        super(FakeScopes, self).setUp()
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
