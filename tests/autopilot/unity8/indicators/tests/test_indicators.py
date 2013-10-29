# -*- Mode: Python; coding: utf-8; indent-tabs-mode: nil; tab-width: 4 -*-
#
# Unity - Indicators Autopilot Test Suite
# Copyright (C) 2013 Canonical
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

from autopilot import platform
from testtools import skipIf

from unity8.shell.tests import UnityTestCase


class IndicatorTestCase(UnityTestCase):

    scenarios = [
        ('Network', dict(indicator_name='indicator-network')),
        ('Location', dict(indicator_name='indicator-location')),
        ('Messaging', dict(indicator_name='indicator-messages')),
        ('Power', dict(indicator_name='indicator-power')),
        ('Sound', dict(indicator_name='indicator-sound')),
        ('Datetime', dict(indicator_name='indicator-datetime')),
        ('Bluetooth', dict(indicator_name='indicator-bluetooth')),
    ]

    @skipIf(platform.image_codename()=='Desktop', "phablet-only test")
    def test_indicator_exists(self):
        """The tab of a given indicator can be found."""

        self.launch_unity()
        self.main_window.get_greeter().swipe()
        indicator = self.main_window.get_indicator(self.indicator_name)
        self.assertIsNotNone(indicator)
