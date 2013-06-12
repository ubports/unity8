# -*- Mode: Python; coding: utf-8; indent-tabs-mode: nil; tab-width: 4 -*-
# Copyright 2013 Canonical
#
# This program is free software: you can redistribute it and/or modify it
# under the terms of the GNU General Public License version 3, as published
# by the Free Software Foundation.


# This file contains general purpose test cases for Unity.
# Each test written in this file will be executed for a variety of
# configurations, such as Phone, Tablet or Desktop form factors.
#
# Sometimes there is the need to disable a certain test for a particular
# configuration. To do so, add this in a new line directly below your test:
#
#    test_testname.blacklist = (FormFactors.Tablet, FormFactors.Desktop,)
#
# Available form factors are:
# FormFactors.Phone
# FormFactors.Tablet
# FormFactors.Desktop


"""Tests for the Shell"""

from __future__ import absolute_import

from unity8.tests import ShellTestCase, FormFactors
from unity8.tests.helpers import TestShellHelpers

from autopilot.input import Mouse, Touch, Pointer
from testtools.matchers import Equals, NotEquals, GreaterThan, MismatchError
from autopilot.matchers import Eventually
from autopilot.display import Display
from autopilot.platform import model

import unittest
import time
import os
from os import path


class TestLockscreens(ShellTestCase, TestShellHelpers):

    """Tests the Lockscreens"""

    # Scenarios:
    # Fill in the scenarios to run the whole test suite with multiple configurations.
    # Use app_width, app_height and grid_unit_px to set the apps geometry.
    # Set app_width and app_height to 0 to use fullscreen.
    # Set grid_unit_px to 0 to use the current system environment.

    if model() == 'Desktop':
        scenarios = [
            ('Pinlock', dict(app_width=768, app_height=1280, grid_unit_px=18, lightdm_mock="single-pin")),
            ('Keylock', dict(app_width=768, app_height=1280, grid_unit_px=18, lightdm_mock="single-passphrase")),
        ]
    else:
        scenarios = [
            ('Pinlock', dict(app_width=0, app_height=0, grid_unit_px=0, lightdm_mock="single-pin")),
            ('Keylock', dict(app_width=0, app_height=0, grid_unit_px=0, lightdm_mock="single-key")),
        ]

    def setUp(self):
        self.touch = Touch.create()

        sg = Display().create()
        divisor = 1
        while (sg.get_screen_width() < self.app_width / divisor or sg.get_screen_height() < self.app_height / divisor):
            divisor = divisor * 2
        super(TestLockscreens, self).setUp("%sx%s" % (self.app_width / divisor, self.app_height / divisor), "%s" % (self.grid_unit_px / divisor))

        dash = self.main_window.get_dash()
        self.assertThat(dash.showLensOnLoaded, Eventually(Equals(""), timeout=30))

    def test_unlock(self):
        self.unlock_greeter()

        pinPadLoader = self.main_window.get_pinPadLoader();
        self.assertThat(pinPadLoader.progress, Eventually(Equals(1)))
        lockscreen = self.main_window.get_lockscreen();
        self.assertThat(lockscreen.shown, Eventually(Equals(True)))

        if self.lightdm_mock == "single-pin":
            self.touch.tap_object(self.main_window.get_pinPadButton(1))
            self.touch.tap_object(self.main_window.get_pinPadButton(2))
            self.touch.tap_object(self.main_window.get_pinPadButton(3))
            self.touch.tap_object(self.main_window.get_pinPadButton(4))
            self.assertThat(lockscreen.shown, Eventually(Equals(False)))
        else:
            pinentryField = self.main_window.get_pinentryField()
            self.touch.tap_object(pinentryField)
            self.keyboard.type("password\n")
            self.assertThat(lockscreen.shown, Eventually(Equals(False)))

    def test_unlock_wrong(self):
        self.unlock_greeter()

        pinPadLoader = self.main_window.get_pinPadLoader();
        self.assertThat(pinPadLoader.progress, Eventually(Equals(1)))
        lockscreen = self.main_window.get_lockscreen();
        self.assertThat(lockscreen.shown, Eventually(Equals(True)))
        pinentryField = self.main_window.get_pinentryField()

        if self.lightdm_mock == "single-pin":
            self.touch.tap_object(self.main_window.get_pinPadButton(4))
            self.touch.tap_object(self.main_window.get_pinPadButton(3))
            self.touch.tap_object(self.main_window.get_pinPadButton(2))
            self.assertThat(pinentryField.text, Eventually(Equals("432")))
            self.touch.tap_object(self.main_window.get_pinPadButton(1))

            self.assertThat(pinentryField.text, Eventually(Equals("")))
            self.assertThat(lockscreen.shown, Eventually(Equals(True)))
        else:
            self.touch.tap_object(pinentryField)
            self.keyboard.type("foobar\n")
            self.assertThat(pinentryField.text, Eventually(Equals("")))
            self.assertThat(lockscreen.shown, Eventually(Equals(True)))
