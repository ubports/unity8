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


from autopilot.introspection import CustomEmulatorBase
from time import sleep


class UnityEmulatorBase(CustomEmulatorBase):
    """A base class for all unity emulators."""

    def _drag(self, x1, y1, x2, y2):
        cur_x = x1
        cur_y = y1
        dx = 1.0 * (x2 - x1) / 100
        dy = 1.0 * (y2 - y1) / 100
        for i in range(0, 100):
            self.touch._finger_move(int(cur_x), int(cur_y))
            sleep(0.002)
            cur_x += dx
            cur_y += dy
        self.touch._finger_move(int(x2), int(y2))
