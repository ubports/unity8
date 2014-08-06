# -*- Mode: Python; coding: utf-8; indent-tabs-mode: nil; tab-width: 4 -*-
#
# Unity Autopilot Test Suite
# Copyright (C) 2012, 2013, 2014 Canonical
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


from __future__ import absolute_import

from unity8.process_helpers import unlock_unity
from unity8.shell import with_lightdm_mock
from unity8.shell.tests import UnityTestCase, _get_device_emulation_scenarios

from autopilot.matchers import Eventually
import sys
from testtools.matchers import Equals
import logging

logger = logging.getLogger(__name__)

# py2 compatible alias for py3
if sys.version >= '3':
    basestring = str


class TestLockscreen(UnityTestCase):

    """Tests for the lock screen."""

    scenarios = _get_device_emulation_scenarios()

    @with_lightdm_mock("single-pin")
    def test_can_unlock_pin_screen(self):
        """Must be able to unlock the PIN entry lock screen."""
        unity_proxy = self.launch_unity()
        greeter = self.main_window.get_greeter()

        if greeter.narrowMode:
            unlock_unity(unity_proxy)
            lockscreen = self._wait_for_lockscreen()
            self.main_window.enter_pin_code("1234")
            self.assertThat(lockscreen.shown, Eventually(Equals(False)))
        else:
            self._enter_prompt_passphrase("1234")
            self.assertThat(greeter.shown, Eventually(Equals(False)))

    @with_lightdm_mock("single-passphrase")
    def test_can_unlock_passphrase_screen(self):
        """Must be able to unlock the passphrase entry screen."""
        unity_proxy = self.launch_unity()
        greeter = self.main_window.get_greeter()

        if greeter.narrowMode:
            unlock_unity(unity_proxy)
            lockscreen = self._wait_for_lockscreen()
            self._enter_pin_passphrase("password")
            self.assertThat(lockscreen.shown, Eventually(Equals(False)))
        else:
            self._enter_prompt_passphrase("password")
            self.assertThat(greeter.shown, Eventually(Equals(False)))

    @with_lightdm_mock("single-pin")
    def test_pin_screen_wrong_code(self):
        """Entering the wrong pin code must not dismiss the lock screen."""
        unity_proxy = self.launch_unity()
        greeter = self.main_window.get_greeter()

        if greeter.narrowMode:
            unlock_unity(unity_proxy)
            lockscreen = self._wait_for_lockscreen()
            self.main_window.enter_pin_code("4321")
            pinentryField = self.main_window.get_pinentryField()
            self.assertThat(pinentryField.text, Eventually(Equals("")))
            self.assertThat(lockscreen.shown, Eventually(Equals(True)))
        else:
            self._enter_prompt_passphrase("4231")
            prompt = self.main_window.get_greeter().get_prompt()
            self.assertThat(prompt.text, Eventually(Equals("")))
            self.assertThat(greeter.shown, Eventually(Equals(True)))

    @with_lightdm_mock("single-passphrase")
    def test_passphrase_screen_wrong_password(self):
        """Entering the wrong password must not dismiss the lock screen."""
        unity_proxy = self.launch_unity()
        greeter = self.main_window.get_greeter()

        if greeter.narrowMode:
            unlock_unity(unity_proxy)
            lockscreen = self._wait_for_lockscreen()
            self._enter_pin_passphrase("foobar")
            pinentryField = self.main_window.get_pinentryField()
            self.assertThat(pinentryField.text, Eventually(Equals("")))
            self.assertThat(lockscreen.shown, Eventually(Equals(True)))
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
        pin_entry_field.write(passphrase)
        logger.debug("Typed passphrase: %s", pin_entry_field.text)
        self.keyboard.type("\n")

    def _enter_prompt_passphrase(self, passphrase):
        """Enter the password specified in 'passphrase' into the password entry
        field of the main user list's prompt.

        :param passphrase: The string you want to enter.
        :raises: TypeError if passphrase is not a string.

        """
        if not isinstance(passphrase, basestring):
            raise TypeError(
                "'passphrase' parameter must be a string, not %r."
                % type(passphrase)
            )

        prompt = self.main_window.get_greeter().get_prompt()
        prompt.write(passphrase)
        logger.debug("Typed passphrase: %s", prompt.text)
        self.keyboard.type("\n")
