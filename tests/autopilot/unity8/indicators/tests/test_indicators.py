# -*- Mode: Python; coding: utf-8; indent-tabs-mode: nil; tab-width: 4 -*-
#
# Unity Indicators Autopilot Test Suite
# Copyright (C) 2013, 2014, 2015 Canonical
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

import platform

from testscenarios import multiply_scenarios

import autopilot.platform

from unity8.indicators import tests


class IndicatorExistsTestCase(tests.DeviceIndicatorTestCase):

    indicator_scenarios = [
        ('Bluetooth', dict(indicator_name='indicator-bluetooth')),
        ('Datetime', dict(indicator_name='indicator-datetime')),
        ('Location', dict(indicator_name='indicator-location')),
        ('Messaging', dict(indicator_name='indicator-messages')),
        ('Network', dict(indicator_name='indicator-network')),
        ('Power', dict(indicator_name='indicator-power')),
        ('Sound', dict(indicator_name='indicator-sound')),
    ]
    scenarios = multiply_scenarios(
        indicator_scenarios,
        tests.IndicatorTestCase.device_emulation_scenarios
    )

    def test_indicator_exists(self):
        self.main_window._get_indicator_panel_item(
            self.indicator_name
        )


class IndicatorPageTitleMatchesWidgetTestCase(tests.DeviceIndicatorTestCase):

    indicator_scenarios = [
        ('Bluetooth', dict(indicator_name='indicator-bluetooth',
                           title='Bluetooth')),
        ('Datetime', dict(indicator_name='indicator-datetime',
                          title='Time & Date')),
        ('Location', dict(indicator_name='indicator-location',
                          title='Location')),
        ('Messaging', dict(indicator_name='indicator-messages',
                           title='Notifications')),
        ('Network', dict(indicator_name='indicator-network',
                         title='Network')),
        ('Power', dict(indicator_name='indicator-power',
                       title='Battery')),
        ('Sound', dict(indicator_name='indicator-sound',
                       title='Sound')),
    ]
    scenarios = multiply_scenarios(
        indicator_scenarios,
        tests.IndicatorTestCase.device_emulation_scenarios
    )

    def test_indicator_page_title_matches_widget(self):
        """Swiping open an indicator must show its correct title.

        See https://bugs.launchpad.net/ubuntu-ux/+bug/1253804 .
        """
        indicator_page = self.main_window.open_indicator_page(
            self.indicator_name)
        if self.indicator_name == 'indicator-bluetooth':
            if autopilot.platform.model() == 'Nexus 10':
                self.expectFailure('Nexus 10 does not have bluetooth at the moment.',
                                   self.assertTrue, indicator_page.visible)
            if platform.linux_distribution()[2] == 'wily':
                self.expectFailure('Bluetooth doesn\'t work on wily at the moment.',
                                   self.assertTrue, indicator_page.visible)
        self.assertTrue(indicator_page.visible)
        self.assertEqual(indicator_page.title, self.title)
