# -*- Mode: Python; coding: utf-8; indent-tabs-mode: nil; tab-width: 4 -*-
#
# Unity Autopilot Test Suite
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
#

import dbus

from autopilot.matchers import Eventually
from testtools.matchers import Equals


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


def _get_greeter_dbus_proxy():
    bus = dbus.SessionBus()
    return bus.get_object('com.canonical.UnityGreeter', '/')


def _is_greeter_active():
    try:
        dbus_proxy = _get_greeter_dbus_proxy()
        return dbus_proxy.Get('com.canonical.UnityGreeter', 'IsActive')
    except:
        return False
