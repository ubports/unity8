# -*- Mode: Python; coding: utf-8; indent-tabs-mode: nil; tab-width: 4 -*-
# Copyright 2013 Canonical
#
# This program is free software: you can redistribute it and/or modify it
# under the terms of the GNU General Public License version 3, as published
# by the Free Software Foundation.

"""Add tests here if you want to ensure the behaviour of the power indicator menus are correct"""

from testtools.matchers import Equals, NotEquals
from autopilot.input import Touch
from autopilot.matchers import Eventually

from unity8.indicators_client.tests import IndicatorsTestCase
from time import sleep
import random
import math
import unittest

class TestDisplayMenus(IndicatorsTestCase):
    def setUp(self):
        super(TestDisplayMenus, self).setUp(self.geometry, self.grid_unit)

    def tearDown(self):
        # self.main_window.get_indicators_client().reset()
        super(TestDisplayMenus, self).tearDown()

    # START SECTION
    # We need to move these to emulators once autopilot supports emulators for
    # applications started with AutopilotTestCase.launch_test_application

    def open_battery_menu(self):
        # This opens the messaging menu so you don't have to do that in
        # every test case
        self.assertThat(lambda: self.main_window.get_battery_menu(), Eventually(NotEquals(None)));
        self.pointing_device.move_to_object(self.main_window.get_battery_menu())
        self.pointing_device.click()

        fn_loader = lambda: self.app.select_single("IndicatorsPage/QQuickLoader", objectName="pageLoader");
        self.assertThat(fn_loader, Eventually(NotEquals(None)));
        page_loader = fn_loader();
        self.assertThat(page_loader.progress, Eventually(Equals(1.0)))

    def switch_auto_brightness(self, auto_brightness):
        ab_switch = auto_brightness.select_single("CheckBox");
        self.assertThat(ab_switch, NotEquals(None))

        self.pointing_device.move_to_object(ab_switch)
        self.pointing_device.click()

    def set_brightness_to_value(self, brightness_menu, new_value):
        brightness_slider = brightness_menu.select_single("Slider");
        self.assertThat(brightness_slider, NotEquals(None))

        self.pointing_device.move_to_object(brightness_slider)

        old_ab_value = brightness_slider.value
        pixel_ratio = brightness_slider.width / (brightness_slider.maximumValue - brightness_slider.minimumValue)

        while True:

            pixels_to_move = int(pixel_ratio * (new_value - old_ab_value) / 15)
            if pixels_to_move == 0:
                break;

            self.pointing_device.drag(self.pointing_device.x, self.pointing_device.y, self.pointing_device.x + pixels_to_move, self.pointing_device.y)

            old_ab_value = brightness_slider.value

    @unittest.skip("Battery indicator has been removed.")
    def test_auto_bright_switch(self):
        """Test the auto-bright switch"""
        self.open_battery_menu()

        # wait for the switch menu item
        fn_auto_brightness = lambda: self.app.select_single("SwitchMenuItem", objectName="auto-brightness");
        # FIXME: this should go away when we switch to indicator-power
        try:
            self.assertThat(fn_auto_brightness, Eventually(NotEquals(None)));
        except AssertionError:
            self.skipTest("WARNING: test skipped due to missing indicator-battery")
        auto_brightness = fn_auto_brightness();

        old_ab_value = auto_brightness.checked

        self.switch_auto_brightness(auto_brightness)

        # TODO - should check backend when it's introspectable.
        self.assertThat(auto_brightness.checked, Eventually(NotEquals(old_ab_value)))

    @unittest.skip("Battery indicator has been removed.")
    def test_brightness_slider(self):
        """Test the auto-bright switch"""
        self.open_battery_menu()

        fn_brightness_menu = lambda: self.app.select_single("SliderMenuItem", objectName="brightness");
        # FIXME: this should go away when we switch to indicator-power
        try:
            self.assertThat(fn_brightness_menu, Eventually(NotEquals(None)));
        except AssertionError:
            self.skipTest("WARNING: test skipped due to missing indicator-battery")
        brightness_menu = fn_brightness_menu();

        old_ab_value = brightness_menu.value
        # find a new value to do to. At least 1/4 distance away from current value
        while True:
            desired_value = random.uniform(brightness_menu.minimumValue, brightness_menu.maximumValue)
            if (abs(desired_value - old_ab_value) >= (brightness_menu.maximumValue - brightness_menu.minimumValue)/4):
                break;

        self.set_brightness_to_value(brightness_menu, desired_value)

        # TODO - should check backend when it's introspectable.
        self.assertThat(brightness_menu.value, Eventually(NotEquals(old_ab_value)))
