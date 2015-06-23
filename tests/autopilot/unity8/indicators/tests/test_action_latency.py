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

from testscenarios import multiply_scenarios

from unity8 import (
    fixture_setup,
    indicators,
)
from unity8.indicators import tests

from autopilot.matchers import Eventually
from testtools.matchers import Equals, NotEquals


class TestIndicatorBaseTestCase(tests.IndicatorTestCase):

    scenarios = [tests.IndicatorTestCase.device_emulation_scenarios[0]]

    def setUp(self):
        super(TestIndicatorBaseTestCase, self).setUp()

        self.launch_indicator_service()

        # wait for the indicator to appear in unity
        self.indicator = indicators.TestIndicator(self.main_window)
        self.assertThat(
            self.indicator.is_indicator_icon_visible(),
            Eventually(Equals(True), timeout=20)
        )
        self.indicator_page = self.indicator.open()

    def launch_indicator_service(self):
        launch_service_fixture = \
            fixture_setup.LaunchMockIndicatorService(self.action_delay)
        self.useFixture(launch_service_fixture)


class TestServerValueUpdate(TestIndicatorBaseTestCase):

    """Test that an action causes the server to update"""

    time_scenarios = [
        ('Low', {'action_delay': 0}),
        ('Medium', {'action_delay': 2500}),
        ('High', {'action_delay': 8000}),
    ]
    scenarios = multiply_scenarios(
        time_scenarios,
        TestIndicatorBaseTestCase.scenarios
    )

    def test_switch_reaches_server_value(self):
        switch = self.indicator_page.get_switcher()
        switch_menu = self.indicator_page.get_switch_menu()

        switch.change_state()
        final_value = switch.checked

        self.assertThat(
            switch_menu.serverChecked,
            Eventually(Equals(final_value), timeout=20)
        )

    def test_slider_reaches_server_value(self):
        slider = self.indicator_page.get_slider()
        slider_menu = self.indicator_page.get_slider_menu()

        old_value = slider.value
        slider.slide_left()
        final_value = slider.value

        self.assertThat(
            slider_menu.serverValue,
            Eventually(NotEquals(old_value), timeout=20)
        )

        self.assertThat(
            slider_menu.serverValue,
            Eventually(Equals(final_value), timeout=20)
        )


class TestBuffering(TestIndicatorBaseTestCase):

    """Test that switching multiple times will buffer activations

    See https://bugs.launchpad.net/ubuntu/+source/unity8/+bug/1390136 .
    """
    action_delay = 2500

    def test_switch_buffers_actvations(self):

        switch = self.indicator_page.get_switcher()
        switch.change_state()
        intermediate_value = switch.checked

        # will buffer change until it receives the change from server
        switch.change_state()
        final_value = switch.checked

        # backend will respond to first switch.
        switch_menu = self.indicator_page.get_switch_menu()
        self.assertThat(
            switch_menu.serverChecked,
            Eventually(Equals(intermediate_value), timeout=20)
        )
        # The buffered activation should have gone to server now.

        # front-end should not change as a result of server update
        # while it is buffered
        self.assertThat(
            switch.checked,
            Equals(final_value)
        )

        # server will respond to the second activate
        self.assertThat(
            switch_menu.serverChecked,
            Eventually(Equals(final_value), timeout=20)
        )

        # make sure we've got the server value set.
        self.assertThat(
            switch.checked,
            Equals(switch_menu.serverChecked)
        )

    def test_slider_buffers_activations(self):

        slider = self.indicator_page.get_slider()
        original_value = slider.value
        slider.slide_left()

        # will buffer change until it receives the change from server
        slider.slide_right()
        final_value = slider.value

        # backend will respond to first slider. Since it's a live slider
        # it'll probably be a random value along the slide.
        slider_menu = self.indicator_page.get_slider_menu()
        self.assertThat(
            slider_menu.serverValue,
            Eventually(NotEquals(original_value), timeout=20)
        )
        # It wont yet have reached the final value due to the buffering
        # Second activate should have gone out by now
        self.assertThat(
            slider_menu.serverValue,
            NotEquals(final_value)
        )

        # front-end should not change as a result of server update
        # while it is buffered
        self.assertThat(
            slider.value,
            Equals(final_value)
        )

        # server will respond to the second activate
        self.assertThat(
            slider_menu.serverValue,
            Eventually(Equals(final_value), timeout=20)
        )

        # make sure we've got the server value set.
        self.assertThat(
            slider.value,
            Equals(slider_menu.serverValue)
        )


class TestClientRevertsToServerValue(TestIndicatorBaseTestCase):

    """Test that an action which does not respond in time will revert
    to original value if not actioned in time.

    See https://bugs.launchpad.net/ubuntu/+source/unity8/+bug/1390136 .
    """
    action_delay = -1  # never action.

    def test_switch_reverts_on_late_response(self):

        switch = self.indicator_page.get_switcher()
        switch_menu = self.indicator_page.get_switch_menu()

        original_value = switch.checked
        switch.change_state()

        # switch should revert to original value after 5 seconds
        # (30 seconds in real usage)
        self.assertThat(
            switch.checked,
            Eventually(Equals(original_value), timeout=20)
        )

        # make sure we've got the server value set.
        self.assertThat(
            switch.checked,
            Equals(switch_menu.serverChecked)
        )

    def test_slider_reverts_on_late_response(self):

        slider = self.indicator_page.get_slider()
        slider_menu = self.indicator_page.get_slider_menu()

        original_value = slider.value
        slider.slide_left()

        # slider should revert to original value after 5 seconds
        # (30 seconds in real usage)
        self.assertThat(
            slider.value,
            Eventually(Equals(original_value), timeout=20)
        )

        # make sure we've got the server value set.
        self.assertThat(
            slider.value,
            Equals(slider_menu.serverValue)
        )
