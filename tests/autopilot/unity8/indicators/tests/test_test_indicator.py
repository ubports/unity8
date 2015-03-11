# -*- Mode: Python; coding: utf-8; indent-tabs-mode: nil; tab-width: 4 -*-
#
# Unity Indicators Autopilot Test Suite
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

from unity8 import (
    fixture_setup,
    indicators,
    get_binary_path,
    process_helpers
)
from unity8.indicators import tests

from autopilot.matchers import Eventually
from testtools.matchers import Equals
import time

class TestIndicatorBaseTestCase(tests.IndicatorTestCase):

    scenarios = tests.IndicatorTestCase.device_emulation_scenarios

    def setUp(self, action_delay=30000):
        """
        :parameter action_delay: number of milliseconds for indicator backend
                to wait before performing actions
        """
        super(TestIndicatorBaseTestCase, self).setUp()

        self.ensure_service_not_running();

        binary_path = get_binary_path('unity-indicator-test-service')
        environment = {}
        environment['ARGS'] = '-t {0}'\
            .format(action_delay)
        self.launch_indicator_service(binary_path, environment)

        # wait for the indicator to appear in unity
        self.indicator = indicators.TestIndicator(self.main_window)
        self.assertThat(
            self.indicator.is_indicator_icon_visible(),
            Eventually(Equals(True), timeout=20)
        )
        self.indicator_page = self.indicator.open()

    def launch_indicator_service(self, binary_path, variables):
        launch_service_fixture = fixture_setup.LaunchTestIndicatorService(binary_path, variables)
        self.useFixture(launch_service_fixture)

    def ensure_service_not_running(self):
        if process_helpers.is_job_running('unity-indicator-test-service'):
            process_helpers.stop_job('unity-indicator-test-service')


class TestLowLatencyIndicator(TestIndicatorBaseTestCase):

    def setUp(self):
        """Set up for indicator actions to take 50 milliseconds for be actioned"""
        super(TestLowLatencyIndicator, self).setUp(50)


    def test_switch_reaches_server_value(self):
        """Test that switching causes the server to update"""
        self.assertThat(
            self.indicator_page.get_switch_menu().serverChecked,
            Equals(self.indicator_page.get_switcher().checked)
        )

        self.indicator_page.get_switcher().change_state()

        self.assertThat(
            self.indicator_page.get_switch_menu().serverChecked,
            Eventually(Equals(self.indicator_page.get_switcher().checked), timeout=10)
        )

class TestMediumLatencyIndicator(TestIndicatorBaseTestCase):

    def setUp(self):
        """Set up for indicator actions to take 2.5 seconds for be actioned"""
        super(TestMediumLatencyIndicator, self).setUp(2500)

    def test_buffered_switch(self):
        """Test that switching multiple times will buffer activations if
        within the activation timeout period

        See https://bugs.launchpad.net/ubuntu/+source/unity8/+bug/1390136 .
        """
        self.indicator_page.get_switcher().change_state()
        # will buffer change until it receives the change from server
        self.indicator_page.get_switcher().change_state()
        new_value = self.indicator_page.get_switcher().checked;

        # backend will respond to first switch. The buffered activation should have gone to server now.
        self.assertThat(
            self.indicator_page.get_switch_menu().serverChecked,
            Eventually(Equals(not new_value), timeout=15)
        )

        # front-end should not change while it is buffered
        self.assertThat(
            self.indicator_page.get_switcher().checked,
            Equals(new_value)
        )

        # server will respond to the second activate
        self.assertThat(
            self.indicator_page.get_switch_menu().serverChecked,
            Eventually(Equals(new_value), timeout=15)
        )

        # make sure we've got the server value set.
        self.assertThat(
            self.indicator_page.get_switcher().checked,
            Equals(self.indicator_page.get_switch_menu().serverChecked)
        )



class TestHighLatencyIndicator(TestIndicatorBaseTestCase):

    def setUp(self):
        """Set up for indicator actions to take 8 seconds for be actioned"""
        super(TestHighLatencyIndicator, self).setUp(8000)

    def test_switch_reverts_to_server_value(self):
        """Test that switching a high latency backend value will revert to original value
        if not actioned in time.

        See https://bugs.launchpad.net/ubuntu/+source/unity8/+bug/1390136 .
        """
        self.assertThat(
            self.indicator_page.get_switch_menu().serverChecked,
            Equals(self.indicator_page.get_switcher().checked)
        )

        original_value = self.indicator_page.get_switcher().checked;
        self.indicator_page.get_switcher().change_state()

        # switch should revert to original value after 5 seconds (30 seconds in real usage)
        self.assertThat(
            self.indicator_page.get_switch_menu().serverChecked,
            Eventually(Equals(original_value), timeout=15)
        )
        # value will eventually switch back. See test_switch_always_reaches_server_value

    def test_switch_always_reaches_server_value(self):
        """Test that switching a high latency backend value will always end up following the
        server value, even if had a reversion

        See https://bugs.launchpad.net/ubuntu/+source/unity8/+bug/1390136 .
        """
        self.test_switch_reverts_to_server_value()

        self.assertThat(
            self.indicator_page.get_switch_menu().serverChecked,
            Eventually(Equals(self.indicator_page.get_switcher().checked), timeout=15)
        )

    def test_revert_on_late_response(self):
        """If the server does not respond in the given amount of time
        then we wont switch again even if the switch is buffered

        See https://bugs.launchpad.net/ubuntu/+source/unity8/+bug/1390136 .
        """
        self.indicator_page.get_switcher().change_state()
        # will buffer change until it receives the change from server
        self.indicator_page.get_switcher().change_state()
        new_value = self.indicator_page.get_switcher().checked;

        # backend will respond to first switch. The buffered activation will be discarded
        self.assertThat(
            self.indicator_page.get_switch_menu().serverChecked,
            Eventually(Equals(not new_value), timeout=15)
        )

        # make sure we've got the server value set.
        self.assertThat(
            self.indicator_page.get_switcher().checked,
            Equals(self.indicator_page.get_switch_menu().serverChecked)
        )
