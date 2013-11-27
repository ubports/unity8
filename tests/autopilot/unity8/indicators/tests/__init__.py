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

from __future__ import absolute_import

from autopilot.input import Pointer, Touch

from unity8.shell.tests import UnityTestCase


# TODO: submit to autopilot.introspection.types.Rectangle
def get_center(global_rect):
    """Returns (x, y) representing the center of a globalRect."""
    return (global_rect[0]+int(global_rect[2]/2),
            global_rect[1]+int(global_rect[3]/2))


class IndicatorBaseTestCase(UnityTestCase):

    def setUp(self):
        super(IndicatorBaseTestCase, self).setUp()
        self.pointer = Pointer(Touch.create())

    # Because some tests are manually manipulating the finger, we want to
    # cleanup if the test fails, but we don't want to fail with an exception if
    # we don't.
    def _maybe_release_finger(self):
        """Only release the finger if it is in fact down."""
        if self.touch._touch_finger is not None:
            self.touch.release()

    def swipe_to_open_indicator(self, indicator_widget, window):
        """Swipe to open the indicator, wait until it's open."""
        start_x, start_y = get_center(indicator_widget.globalRect)
        end_x = start_x
        end_y = window.height
        self.pointer.drag(start_x, start_y,
                          end_x, end_y)
        self.addCleanup(self._maybe_release_finger)
        # TODO: assert that the indicator page opened

    def swipe_to_close_indicator(self, indicator_widget, window):
        """Swipe to close the indicator, wait until it's closed."""
        end_x, end_y = get_center(indicator_widget.globalRect)
        start_x = end_x
        start_y = window.height
        self.pointer.drag(start_x, start_y,
                          end_x, end_y)
        self.addCleanup(self._maybe_release_finger)
        # TODO: assert that the indicator page closed
