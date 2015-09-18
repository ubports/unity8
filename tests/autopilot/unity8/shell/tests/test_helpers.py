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

"""Tests for the Dash autopilot custom proxy objects.

The autopilot custom proxy objects are helpers for tests that check a user
journey that involves the dash. The code for some of those tests will not be
inside this branch, but in projects that depend on unity or that test the
whole system integration. So, we need to test the helpers in order to make
sure that we don't break them for those external projects.

"""

from ubuntuuitoolkit import ubuntu_scenarios

from unity8 import process_helpers
from unity8.shell import fixture_setup, tests
from unity8 import dash as dash_helpers


class MainWindowTestCase(tests.UnityTestCase):

    scenarios = ubuntu_scenarios.get_device_simulation_scenarios()

    def setUp(self):
        super().setUp()
        self.launch_unity()
        process_helpers.unlock_unity()


class DashHelperTestCase(tests.DashBaseTestCase):

    def test_search(self):
        self.dash.enter_search_query('Test', self.keyboard)
        text_field = self.dash.get_search_text_field()
        self.assertEqual(text_field.text, 'Test')

    def test_open_scope_to_the_right(self):
        leftmost_scope = self._get_leftmost_scope_id()
        self.dash.open_scope(leftmost_scope)

        scope_id = self._get_rightmost_scope_id()
        scope = self.dash.open_scope(scope_id)
        self._assert_scope_is_opened(scope, scope_id)

    def _assert_scope_is_opened(self, scope, scope_id):
        self.assertTrue(scope.isCurrent)
        scope_loader = scope.get_parent()
        self.assertEqual(scope_loader.scopeId, scope_id)

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
        scope_id = 'musicaggregator'
        scope = self.dash.open_scope(scope_id)
        self._assert_scope_is_opened(scope, scope_id)
        self.assertIsInstance(scope, dash_helpers.GenericScopeView)

    def test_open_applications_scope(self):
        scope_id = 'clickscope'
        scope = self.dash.open_scope(scope_id)
        self._assert_scope_is_opened(scope, scope_id)
        self.assertIsInstance(scope, dash_helpers.GenericScopeView)


class GenericScopeViewHelperTestCase(tests.DashBaseTestCase):

    def setUp(self):
        # Set up the fake scopes before launching unity.
        self.useFixture(fixture_setup.FakeScopes())
        super().setUp()
        self.generic_scope = self.dash.open_scope('MockScope1')

    def test_open_preview(self):
        preview = self.generic_scope.open_preview('0', 'Title.0.0')
        self.assertIsInstance(preview, dash_helpers.Preview)
        self.assertTrue(preview.isCurrent)

    def test_open_preview_of_non_visible_item(self):
        """Open an item that requires swiping to make it visible."""
        preview = self.generic_scope.open_preview('2', 'Title.2.0')
        self.assertIsInstance(preview, dash_helpers.Preview)
        self.assertTrue(preview.isCurrent)


class DashAppsHelperTestCase(tests.DashBaseTestCase):

    available_applications = [
        'Title.2.0', 'Title.2.1', 'Title.2.2',  'Title.2.3', 'Title.2.4',
        'Title.2.5', 'Title.2.6', 'Title.2.7',  'Title.2.8', 'Title.2.9',
        'Title.2.10', 'Title.2.11', 'Title.2.12']

    def setUp(self):
        # Set up the fake scopes before launching unity.
        self.useFixture(fixture_setup.FakeScopes())
        super().setUp()
        self.applications_scope = self.dash.open_scope('clickscope')

    def test_get_applications_should_return_correct_applications(self):
        category = '2'
        category_element = self.applications_scope._get_category_element(
            category)
        list_view = self.dash.get_scope('clickscope')\
            .select_single(dash_helpers.ListViewWithPageHeader)
        expected_apps_count = self._get_number_of_application_slots(category)
        expected_applications = self.available_applications[
            :expected_apps_count]
        x_center = list_view.globalRect.x + list_view.width / 2
        y_center = list_view.globalRect.y + list_view.height / 2
        y_diff = (
            category_element.y - list_view.height + category_element.height
        )
        list_view._slow_drag(x_center, x_center, y_center, y_center - y_diff)
        applications = self.applications_scope.get_applications(category)
        self.assertEqual(expected_applications, applications)

    def _get_number_of_application_slots(self, category):
        category_element = self.applications_scope._get_category_element(
            category)
        cardgrid = category_element.select_single('CardGrid')
        if (category_element.expanded):
            return cardgrid.select_single('QQuickGridView').count
        else:
            return cardgrid.collapsedRows \
                * cardgrid.select_single('ResponsiveGridView').columns
