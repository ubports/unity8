# -*- Mode: Python; coding: utf-8; indent-tabs-mode: nil; tab-width: 4 -*-
#
# Unity Autopilot Test Suite
# Copyright (C) 2012, 2013, 2014, 2015 Canonical
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

import logging

from autopilot.matchers import Eventually
from testtools.matchers import Equals
from ubuntuuitoolkit import ubuntu_scenarios

from unity8.shell.tests import UnityTestCase


logger = logging.getLogger(__name__)


class TestLockscreen(UnityTestCase):

    """Tests for the lock screen."""

    scenarios = ubuntu_scenarios.get_device_simulation_scenarios()

    def test_can_unlock_pin_screen(self):
        """Must be able to unlock the PIN entry lock screen."""

        self._environment['LIBLIGHTDM_MOCK_MODE'] = "single-pin"
        self.launch_unity()
        greeter = self.main_window.get_greeter()

        if not greeter.tabletMode:
            greeter.swipe()
            self._wait_for_lockscreen()
            self.main_window.enter_pin_code("1234")
        else:
            self._enter_prompt_passphrase("1234\n")
        self.assertThat(greeter.shown, Eventually(Equals(False)))

    def test_can_unlock_passphrase_screen(self):
        """Must be able to unlock the passphrase entry screen."""

        self._environment['LIBLIGHTDM_MOCK_MODE'] = "single-passphrase"
        self.launch_unity()
        greeter = self.main_window.get_greeter()

        if not greeter.tabletMode:
            greeter.swipe()
            self._wait_for_lockscreen()
            self._enter_pin_passphrase("password")
        else:
            self._enter_prompt_passphrase("password")
        self.assertThat(greeter.shown, Eventually(Equals(False)))

    def test_pin_screen_wrong_code(self):
        """Entering the wrong pin code must not dismiss the lock screen."""
        self._environment['LIBLIGHTDM_MOCK_MODE'] = "single-pin"
        self.launch_unity()
        greeter = self.main_window.get_greeter()

        if not greeter.tabletMode:
            greeter.swipe()
            self._wait_for_lockscreen()
            self.main_window.enter_pin_code("4321")
            pinentryField = self.main_window.get_pinentryField()
            self.assertThat(pinentryField.text, Eventually(Equals("")))
        else:
            self._enter_prompt_passphrase("4231\n")
            prompt = self.main_window.get_greeter().get_prompt()
            self.assertThat(prompt.text, Eventually(Equals("")))
        self.assertThat(greeter.shown, Eventually(Equals(True)))

    def test_passphrase_screen_wrong_password(self):
        """Entering the wrong password must not dismiss the lock screen."""
        self._environment['LIBLIGHTDM_MOCK_MODE'] = "single-passphrase"
        self.launch_unity()
        greeter = self.main_window.get_greeter()

        if not greeter.tabletMode:
            greeter.swipe()
            self._wait_for_lockscreen()
            self._enter_pin_passphrase("foobar")
            pinentryField = self.main_window.get_pinentryField()
            self.assertThat(pinentryField.text, Eventually(Equals("")))
        else:
            self._enter_prompt_passphrase("foobar")
            prompt = self.main_window.get_greeter().get_prompt()
            self.assertThat(prompt.text, Eventually(Equals("")))
        self.assertThat(greeter.shown, Eventually(Equals(True)))

    def _wait_for_lockscreen(self):
        """Wait for the lock screen to load, and return it."""
        pinPadLoader = self.main_window.get_pinPadLoader()
        self.assertThat(pinPadLoader.progress, Eventually(Equals(1)))
        lockscreen = self.main_window.get_lockscreen()
        self.assertThat(lockscreen.shown, Eventually(Equals(True)))
        return lockscreen

    def _enter_pin_passphrase(self, passphrase):
        """Enter the password specified in 'passphrase' into the password entry
        field of the pin lock screen.

        :param passphrase: The string you want to enter.
        :raises: TypeError if passphrase is not a string.

        """
        if not isinstance(passphrase, str):
            raise TypeError(
                "'passphrase' parameter must be a string, not %r."
                % type(passphrase)
            )

        pin_entry_field = self.main_window.get_pinentryField()
        # pinentryField should automatically have focus
        self.keyboard.type(passphrase)
        logger.debug("Typed passphrase: %s", pin_entry_field.text)
        self.assertEqual(pin_entry_field.text, passphrase)
        self.keyboard.type("\n")

    def _enter_prompt_passphrase(self, passphrase):
        """Enter the password specified in 'passphrase' into the password entry
        field of the main user list's prompt.

        :param passphrase: The string you want to enter.
        :raises: TypeError if passphrase is not a string.

        """
        if not isinstance(passphrase, str):
            raise TypeError(
                "'passphrase' parameter must be a string, not %r."
                % type(passphrase)
            )

        prompt = self.main_window.get_greeter().get_prompt()
        prompt.write(passphrase)
        logger.debug("Typed passphrase: %s", prompt.text)
        self.keyboard.type("\n")
