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

import logging

import autopilot.logging

from unity8.shell import emulators


logger = logging.getLogger(__name__)


class Launcher(emulators.UnityEmulatorBase):

    """An emulator that understands the Launcher."""

    @autopilot.logging.log_action(logger.debug)
    def show(self):
        """Show the launcher swiping it to the right."""
        if not self.shown:
            self._swipe_launcher('right')
            self.shown.wait_for(True)
        else:
            logger.debug('The launcher is already opened.')

    def _swipe_launcher(self, direction):
        view = self.get_root_instance().select_single('QQuickView')
        start_y = stop_y = view.y + view.height // 2

        left = view.x + 1
        right = left + self.panelWidth - 1

        if direction == 'right':
            start_x = left
            stop_x = right
        elif direction == 'left':
            start_x = right
            stop_x = left

        self.pointing_device.drag(start_x, start_y, stop_x, stop_y)

    @autopilot.logging.log_action(logger.debug)
    def click_dash_icon(self):
        if self.shown:
            dash_icon = self.select_single(
                'QQuickImage', objectName='dashItem')
            self.pointing_device.click_object(dash_icon)
        else:
            raise emulators.UnityEmulatorException('The launcher is closed.')
