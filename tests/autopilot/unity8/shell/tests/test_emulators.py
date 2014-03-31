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

"""Tests for the Dash autopilot emulators.

The autopilot emulators are helpers for tests that check a user journey that
involves the dash. The code for some of those tests will not be inside this
branch, but in projects that depend on unity or that test the whole system
integration. So, we need to test the helpers in order to make sure that we
don't break them for those external projects.

"""

try:
    from unittest import mock
except ImportError:
    import mock

from time import sleep

from testtools.matchers import Contains, HasLength

from unity8 import process_helpers
from unity8.shell import emulators, fixture_setup, tests
from unity8.shell.emulators import dash as dash_emulators


class DashBaseTestCase(tests.UnityTestCase):

    scenarios = tests._get_device_emulation_scenarios()

    def setUp(self):
        super(DashBaseTestCase, self).setUp()
        unity_proxy = self.launch_unity()
        process_helpers.unlock_unity(unity_proxy)
        self.dash = self.main_window.get_dash()


class DashEmulatorTestCase(DashBaseTestCase):

    def test_open_unexisting_scope(self):
        scope_name = 'unexisting'
        with mock.patch.object(self.dash, 'pointing_device') as mock_pointer:
            exception = self.assertRaises(
                emulators.UnityEmulatorException,
                self.dash.open_scope, scope_name)

        self.assertEqual(
            'No scope found with id unexisting', str(exception))
        self.assertFalse(mock_pointer.called)

    def test_open_already_opened_scope(self):
        scope_id = self._get_current_scope_id()
        with mock.patch.object(self.dash, 'pointing_device') as mock_pointer:
            scope = self.dash.open_scope(scope_id)

        self.assertFalse(mock_pointer.called)
        self._assert_scope_is_opened(scope, scope_id)

    def _assert_scope_is_opened(self, scope, scope_id):
        self.assertTrue(scope.isCurrent)
        scope_loader = scope.get_parent()
        self.assertEqual(scope_loader.scopeId, scope_id)

    def _get_current_scope_id(self):
        scope = self.dash.dash_content_list.select_single(
            'QQuickLoader', isCurrent=True)
        return scope.scopeId

    def test_open_scope_to_the_right(self):
        leftmost_scope = self._get_leftmost_scope_id()
        self.dash.open_scope(leftmost_scope)

        scope_id = self._get_rightmost_scope_id()
        scope = self.dash.open_scope(scope_id)
        self._assert_scope_is_opened(scope, scope_id)

    def _get_leftmost_scope_id(self):
        scope_loaders = self._get_scope_loaders()
        leftmost_scope_loader = scope_loaders[0]
        for loader in scope_loaders[1:]:
            if loader.globalRect.x < leftmost_scope_loader.globalRect.x:
                leftmost_scope_loader = loader
        return leftmost_scope_loader.scopeId

    def _get_scope_loaders(self):
        item = self.dash.dash_content_list.get_children_by_type(
            'QQuickItem')[0]
        return item.get_children_by_type('QQuickLoader')

    def _get_rightmost_scope_id(self):
        scope_loaders = self._get_scope_loaders()
        rightmost_scope_loader = scope_loaders[0]
        for loader in scope_loaders[1:]:
            if loader.globalRect.x > rightmost_scope_loader.globalRect.x:
                rightmost_scope_loader = loader
        return rightmost_scope_loader.scopeId

    def test_open_scope_to_the_left(self):
        rightmost_scope = self._get_rightmost_scope_id()
        self.dash.open_scope(rightmost_scope)

        scope_id = self._get_leftmost_scope_id()
        scope = self.dash.open_scope(scope_id)
        self._assert_scope_is_opened(scope, scope_id)

    def test_open_generic_scope(self):
        scope_id = 'scopes'
        scope = self.dash.open_scope(scope_id)
        self._assert_scope_is_opened(scope, scope_id)
        self.assertIsInstance(scope, dash_emulators.GenericScopeView)

    def test_open_applications_scope(self):
        scope_id = 'clickscope'
        scope = self.dash.open_scope(scope_id)
        self._assert_scope_is_opened(scope, scope_id)
        self.assertIsInstance(scope, dash_emulators.DashApps)


class GenericScopeViewEmulatorTestCase(DashBaseTestCase):

    def setUp(self):
        # Set up the fake scopes before launching unity.
        self.useFixture(fixture_setup.FakeScopes())
        super(GenericScopeViewEmulatorTestCase, self).setUp()
        self.generic_scope = self.dash.open_scope('MockScope1')

    def test_open_preview(self):
        preview = self.generic_scope.open_preview('0', 'Title.0.0')
        preview.x.wait_for(0)

class DashAppsEmulatorTestCase(DashBaseTestCase):

    available_applications = [
        'Title.2.0', 'Title.2.1', 'Title.2.2',  'Title.2.3', 'Title.2.4',
        'Title.2.5', 'Title.2.6', 'Title.2.7',  'Title.2.8', 'Title.2.9',
        'Title.2.10', 'Title.2.11', 'Title.2.12']

    def setUp(self):
        # Set up the fake scopes before launching unity.
        self.useFixture(fixture_setup.FakeScopes())
        super(DashAppsEmulatorTestCase, self).setUp()
        self.applications_scope = self.dash.open_scope('clickscope')

    def test_get_applications_with_unexisting_category(self):
        exception = self.assertRaises(
            emulators.UnityEmulatorException,
            self.applications_scope.get_applications,
            'unexisting category')

        self.assertEqual(
            'No category found with name unexisting category', str(exception))

    def test_get_applications_should_return_list_with_names(self):
        category = '2'
        expected_apps_count = self._get_number_of_application_slots(category)
        expected_applications = self.available_applications[
            :expected_apps_count]

        applications = self.applications_scope.get_applications(category)
        applications_titles = []
        for application in applications:
            cardHeader = application.select_single('CardHeader')
            applications_titles.append(cardHeader.title)

        self.assertThat(applications, HasLength(expected_apps_count))
        for expected in expected_applications:
            self.assertThat(applications_titles, Contains(expected))

    def test_get_applications_list_matches_visible_ordering(self):
        category = '2'
        expected_apps_count = self._get_number_of_application_slots(category)
        expected_application_titles = self.available_applications[
            :expected_apps_count]
        applications = self.applications_scope.get_applications(category)
        for card_num in range(len(applications)):
            card_header = applications[card_num].select_single('CardHeader')
            self.assertEqual(expected_application_titles[card_num],
                             card_header.title)

    def _get_number_of_application_slots(self, category):
        category_element = self.applications_scope._get_category_element(
            category)
        grid = category_element.select_single('CardFilterGrid')
        return grid.columns * grid.rows

    def test_open_preview(self):
        preview = self.applications_scope.open_preview('2', 'Title.2.1')
        preview.x.wait_for(0)
