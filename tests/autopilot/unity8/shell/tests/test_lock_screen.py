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

from unity8.shell.tests import Unity8TestCase
from unity8.shell.tests.helpers import with_lightdm_mock

from autopilot.matchers import Eventually
from testtools import skipUnless, skipIf
from autopilot.platform import model
from testtools.matchers import Equals
import logging
import time


logger = logging.getLogger(__name__)


class TestLockscreen(Unity8TestCase):

    """Tests for the lock screen."""

    @with_lightdm_mock("single-pin")
    def test_can_unlock_pin_screen(self):
        """Must be able to unlock the PIN entry lock screen."""
        self.app = self.launch_unity()
        self._unlock_greeter()

        lockscreen = self._wait_for_lockscreen()
        self._enter_pincode("1234")

        self.assertThat(lockscreen.shown, Eventually(Equals(False)))

    @skipUnless(model() == 'Desktop', "Passphrase applicable to desktop only.")
    @with_lightdm_mock("single-passphrase")
    def test_can_unlock_passphrase_screen(self):
        """Must be able to unlock the passphrase entry screen."""
        self.app = self.launch_unity()
        self._unlock_greeter()

        lockscreen = self._wait_for_lockscreen()
        self._enter_passphrase("password")

        self.assertThat(lockscreen.shown, Eventually(Equals(False)))

    @with_lightdm_mock("single-pin")
    def test_pin_screen_wrong_code(self):
        """Entering the wrong pin code must not dismiss the lock screen."""
        self.app = self.launch_unity()
        self._unlock_greeter()

        lockscreen = self._wait_for_lockscreen()
        self._enter_pincode("4321")

        pinentryField = self.main_window.get_pinentryField()
        self.assertThat(pinentryField.text, Eventually(Equals("")))
        self.assertThat(lockscreen.shown, Eventually(Equals(True)))

    @skipUnless(model() == 'Desktop', "Passphrase applicable to desktop only.")
    @with_lightdm_mock("single-passphrase")
    def test_passphrase_screen_wrong_password(self):
        """Entering the wrong password must not dismiss the lock screen."""
        self.app = self.launch_unity()
        self._unlock_greeter()

        lockscreen = self._wait_for_lockscreen()
        self._enter_passphrase("foobar")

        pinentryField = self.main_window.get_pinentryField()
        self.assertThat(pinentryField.text, Eventually(Equals("")))
        self.assertThat(lockscreen.shown, Eventually(Equals(True)))

    def _unlock_greeter(self):
        """Swipe the greeter out of the way."""
        greeter = self.main_window.get_greeter()
        self.assertThat(greeter.created, Eventually(Equals(True)))

        # TODO: Is this ever called? Find out, and maybe remove this branch:
        if greeter.multiUser:
            password_field = self.select_greeter_user("No Password")
            self.assertThat(password_field.opacity, Eventually(Equals(1)))
            self.touch.tap_object(password_field)

        else:
            rect = greeter.globalRect
            start_x = rect[0] + rect[2] - 3
            start_y = int(rect[1] + rect[3] / 2)
            stop_x = int(rect[0] + rect[2] * 0.2)
            stop_y = start_y
            self.touch.drag(start_x, start_y, stop_x, stop_y)

        self.assertThat(greeter.created, Eventually(Equals(False)))

    def _wait_for_lockscreen(self):
        """Wait for the lock screen to load, and return it."""
        pinPadLoader = self.main_window.get_pinPadLoader();
        self.assertThat(pinPadLoader.progress, Eventually(Equals(1)))
        lockscreen = self.main_window.get_lockscreen();
        self.assertThat(lockscreen.shown, Eventually(Equals(True)))
        return lockscreen

    def _enter_pincode(self, code):
        """Enter code 'code' into the single-pin lightdm pincode entry
        screen.

        :param code: must be a string of numeric characters.
        :raises: TypeError if code is not a string.
        :raises: ValueError if code contains non-numeric characters.

        """

        if not isinstance(code, basestring):
            raise TypeError("'code' parameter must be a string.")
        for num in code:
            if not num.isdigit():
                raise ValueError(
                    "'code' parameter contains non-numeric characters."
                )
            self.touch.tap_object(self.main_window.get_pinPadButton(int(num)))

    def _enter_passphrase(self, passphrase):
        """Enter the password specified in 'passphrase' into the password entry
        field.

        :param passphrase: The string you want to enter.
        :raises: TypeError if passphrase is not a string.

        """
        if not isinstance(passphrase, basestring):
            raise TypeError("'passphrase' parameter must be a string.")

        pinentryField = self.main_window.get_pinentryField()
        self.touch.tap_object(pinentryField)
        self.keyboard.type(passphrase)
        self.keyboard.type("\n")



