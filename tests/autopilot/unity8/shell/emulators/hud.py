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
#

from collections import namedtuple

from unity8 import get_grid_size
from unity8.shell.emulators import UnityEmulatorBase
from unity8.shell import DragMixin
from autopilot.input import Touch

SwipeCoords = namedtuple('SwipeCoords', 'start_x end_x start_y end_y')


class Hud(UnityEmulatorBase, DragMixin):

    """An emulator that understands the Hud."""

    def show(self):
        """Swipes open the Hud."""
        self.touch = Touch.create()

        window = self.get_root_instance().wait_select_single('QQuickView')
        hud_show_button = window.wait_select_single("HudButton")

        swipe_coords = self.get_button_swipe_coords(window, hud_show_button)

        self.touch.press(swipe_coords.start_x, swipe_coords.start_y)
        self._drag(
            swipe_coords.start_x,
            swipe_coords.start_y,
            swipe_coords.start_x,
            swipe_coords.end_y
        )
        try:
            hud_show_button.opacity.wait_for(1.0)
            self.touch.release()
            self.shown.wait_for(True)
        except AssertionError:
            raise
        finally:
            # XXX This ugly code is here just temporarily, waiting for uinput
            # improvements to land on autopilot so we don't have to access
            # device private internal attributes. --elopio - 2014-02-12
            try:
                pressed = self.touch._touch_finger is not None
            except AttributeError:
                pressed = self.touch.pressed
            if pressed:
                self.touch.release()

    def dismiss(self):
        """Closes the open Hud."""
        # Ensure that the Hud is actually open
        self.shown.wait_for(True)
        touch = Touch.create()
        x, y = self.get_close_button_coords()
        touch.tap(x, y)
        self.y.wait_for(self.height)

    def get_close_button_coords(self):
        """Returns the coordinates of the Huds close button bar."""
        rect = self.globalRect
        x = int(rect[0] + rect[2] / 2)
        y = rect[1] + get_grid_size()
        return x, y

    def get_button_swipe_coords(self, main_view, hud_show_button):
        """Returns the coords both start and end x,y for swiping to make the
        'hud show' button appear.
        """
        start_x = int(main_view.x + (main_view.width / 2))
        end_x = start_x
        start_y = main_view.y + (main_view.height - 3)
        end_y = main_view.y + int(
            hud_show_button.y + (hud_show_button.height/2)
        )

        return SwipeCoords(start_x, end_x, start_y, end_y)
