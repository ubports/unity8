# -*- Mode: Python; coding: utf-8; indent-tabs-mode: nil; tab-width: 4 -*-
# Copyright 2013 Canonical
#
# This program is free software: you can redistribute it and/or modify it
# under the terms of the GNU General Public License version 3, as published
# by the Free Software Foundation.

"""Add tests here if you want to ensure the behaviour of the power indicator menus are correct"""

from testtools.matchers import Equals, NotEquals
from autopilot.matchers import Eventually

from indicators_client.tests import IndicatorsTestCase
from indicators_client.emulators.common import SwitchMenu
from time import sleep

class TestDisplayMenus(IndicatorsTestCase):
    def setUp(self):
        super(TestDisplayMenus, self).setUp()

        # This opens the messaging menu so you don't have to do that in
        # every test case
        power = self.main_window.get_power_menu()
        self.pointing_device.move_to_object(power)
        self.pointing_device.click()

        self.page = self.app.select_single("IndicatorsPage");
        page_loader = self.app.select_single("IndicatorsPage/QQuickLoader", objectName="page_loader");
        self.assertThat(page_loader.progress, Eventually(Equals(1.0)))

    def tearDown(self):
        # self.main_window.get_indicators_client().reset()
        super(TestDisplayMenus, self).tearDown()

    def test_auto_bright_switch(self):
        """Test the auto-bright switch"""

        auto_brightness = self.app.select_single("SwitchMenu", objectName="auto-brightness")
        self.assertThat(auto_brightness, NotEquals(None))

        old_value = auto_brightness.checked

        print auto_brightness.get_checked()





