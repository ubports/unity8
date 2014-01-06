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

import mock

from unity8.shell import emulators, tests
from unity8.shell.emulators import dash as dash_emulators


class DashEmulatorTestCase(tests.UnityTestCase):

    scenarios = tests._get_device_emulation_scenarios()

    def setUp(self):
        super(DashEmulatorTestCase, self).setUp()
        self.launch_unity()
        self.main_window.get_greeter().swipe()
        self.dash = self.main_window.get_dash()
        self.scope_loaders = self.dash.dash_content_list.select_many(
            'QQuickLoader')

    def test_open_unexisting_scope(self):
        scope_name = 'unexisting'
        with mock.patch.object(self.dash, 'pointing_device') as mock_pointer:
            exception = self.assertRaises(
                emulators.UnityEmulatorException,
                self.dash.open_scope, scope_name)

        self.assertEqual(
            'No scope found with id unexisting.scope', str(exception))
        self.assertFalse(mock_pointer.called)

    def test_open_already_opened_scope(self):
        scope_id = self._get_current_scope_id()
        with mock.patch.object(self.dash, 'pointing_device') as mock_pointer:
            scope = self.dash.open_scope(self._get_scope_name_from_id(
                scope_id))

        self.assertFalse(mock_pointer.called)
        self._assert_scope_is_opened(scope, scope_id)

    def _assert_scope_is_opened(self, scope, scope_id):
        self.assertTrue(scope.isCurrent)
        scope_loader = scope.get_parent()
        self.assertEqual(scope_loader.scopeId, scope_id)

    def _get_current_scope_id(self):
        scope = self.scope_loaders[self.dash.dash_content_list.currentIndex]
        return scope.scopeId

    def test_open_scope_to_the_right(self):
        leftmost_scope = self._get_scope_name_from_id(
            self._get_leftmost_scope_id())
        self.dash.open_scope(leftmost_scope)

        scope_id = self._get_rightmost_scope_id()
        scope = self.dash.open_scope(self._get_scope_name_from_id(scope_id))
        self._assert_scope_is_opened(scope, scope_id)

    def _get_leftmost_scope_id(self):
        scope = self.scope_loaders[0]
        return scope.scopeId

    def _get_scope_name_from_id(self, scope_id):
        if scope_id.endswith('.scope'):
            return scope_id[:-6]

    def _get_rightmost_scope_id(self):
        scope = self.scope_loaders[self.dash.dash_content_list.count - 1]
        return scope.scopeId

    def test_open_scope_to_the_left(self):
        rightmost_scope = self._get_scope_name_from_id(
            self._get_rightmost_scope_id())
        self.dash.open_scope(rightmost_scope)

        scope_id = self._get_leftmost_scope_id()
        scope = self.dash.open_scope(self._get_scope_name_from_id(scope_id))
        self._assert_scope_is_opened(scope, scope_id)

    def test_open_generic_scope(self):
        scope_id = 'home.scope'
        scope = self.dash.open_scope(self._get_scope_name_from_id(scope_id))
        self._assert_scope_is_opened(scope, scope_id)
        self.assertIsInstance(scope, dash_emulators.GenericScopeView)

    def test_open_applications_scope(self):
        scope_id = 'applications.scope'
        scope = self.dash.open_scope(self._get_scope_name_from_id(scope_id))
        self._assert_scope_is_opened(scope, scope_id)
        self.assertIsInstance(scope, dash_emulators.DashApps)
