# -*- Mode: Python; coding: utf-8; indent-tabs-mode: nil; tab-width: 4 -*-
#
# Unity Autopilot Test Suite
# Copyright (C) 2012-2013 Canonical
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

from autopilot.input import Touch

from unity8.indicators.emulators import IndicatorEmulatorBase


class DefaultIndicatorWidget(IndicatorEmulatorBase):

    """The indicator's icon in the menu-bar."""

    # TODO: submit to autopilot.introspection.types.Rectangle
    def get_center(global_rect):
        """Returns (x, y) representing the center of a globalRect."""
        return (self.global_rect[0]+int(self.global_rect[2]/2),
                self.global_rect[1]+int(self.global_rect[3]/2))

    def swipe_to_open_indicator(self, window):
        """Swipe to open the indicator, wait until it's open."""
        start_x, start_y = self.get_center()
        end_x = start_x
        end_y = window.height
        self.pointer.drag(start_x, start_y,
                          end_x, end_y)
        # TODO: assert that the indicator page opened

    def swipe_to_close_indicator(self, window):
        """Swipe to close the indicator, wait until it's closed."""
        end_x, end_y = self.get_center()
        start_x = end_x
        start_y = window.height
        self.pointer.drag(start_x, start_y,
                          end_x, end_y)
        # TODO: assert that the indicator page closed
