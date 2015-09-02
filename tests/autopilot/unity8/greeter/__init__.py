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

import dbus

import ubuntuuitoolkit
from autopilot.matchers import Eventually
from testtools.matchers import Equals
from autopilot.utilities import sleep


def hide_greeter_with_dbus():
    dbus_proxy = _get_greeter_dbus_proxy()
    if _is_greeter_active():
        dbus_proxy.HideGreeter()


def show_greeter_with_dbus():
    dbus_proxy = _get_greeter_dbus_proxy()
    if not _is_greeter_active():
        dbus_proxy.ShowGreeter()


def wait_for_greeter():
    Eventually(Equals(True), timeout=300).match(_is_greeter_active)


def wait_for_greeter_gone():
    Eventually(Equals(False), timeout=300).match(_is_greeter_active)


def _get_greeter_dbus_proxy():
    bus = dbus.SessionBus()
    return bus.get_object('com.canonical.UnityGreeter', '/')


def _is_greeter_active():
    try:
        dbus_proxy = _get_greeter_dbus_proxy()
        return dbus_proxy.Get('com.canonical.UnityGreeter', 'IsActive')
    except:
        return False


class Greeter(ubuntuuitoolkit.UbuntuUIToolkitCustomProxyObjectBase):
    """A helper that understands the greeter screen."""

    def wait_swiped_away(self):
        # We have to be careful here, because coverPage can go away at any time
        # if there isn't a lockscreen behind it (it hides completely, then
        # the greeter disposes it).  But if there *is* a lockscreen, then we
        # need a different check, by looking at its showProgress.  So make our
        # own wait_for loop and check both possibilities.
        for i in range(10):
            if not self.required:
                return
            coverPage = self.select_single(objectName='coverPage')
            if coverPage.showProgress == 0:
                return
            sleep(1)

        raise AssertionError("Greeter cover page still up after 10s")

    def swipe(self):
        """Swipe the greeter screen away."""
        self.waiting.wait_for(False)
        coverPage = self.select_single(objectName='coverPage')
        coverPage.showProgress.wait_for(1)

        rect = self.globalRect
        start_x = rect[0] + rect[2] - 3
        start_y = int(rect[1] + rect[3] / 2)
        stop_x = int(rect[0] + rect[2] * 0.2)
        stop_y = start_y
        self.pointing_device.drag(start_x, start_y, stop_x, stop_y)

        self.wait_swiped_away()

    def get_prompt(self):
        return self.select_single(
            ubuntuuitoolkit.TextField, objectName='passwordInput')
