# -*- Mode: Python; coding: utf-8; indent-tabs-mode: nil; tab-width: 4 -*-
#
# Unity Autopilot Test Suite
# Copyright (C) 2014 Canonical
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
import time

import ubuntuuitoolkit

import autopilot
from autopilot import introspection


logger = logging.getLogger(__name__)


class TutorialPage(
        ubuntuuitoolkit.UbuntuUIToolkitCustomProxyObjectBase):

    @classmethod
    def validate_dbus_object(cls, path, state):
        name = introspection.get_classname_from_path(path)
        return name in (b'TutorialPage', b'TutorialLeft',
                        b'TutorialLeftFinish', b'TutorialRight',
                        b'TutorialBottom', b'TutorialBottomFinish')

    @autopilot.logging.log_action(logger.info)
    def short_swipe_right(self):
        self.shown.wait_for(True)
        x, y, width, height = self.globalRect
        start_x = x
        stop_x = x + width // 3
        start_y = stop_y = y + height // 2
        self.pointing_device.drag(start_x, start_y, stop_x, stop_y)

    @autopilot.logging.log_action(logger.info)
    def swipe_left(self):
        self.shown.wait_for(True)
        x, y, width, height = self.globalRect
        start_x = width
        stop_x = x
        start_y = stop_y = y + height // 2
        self.pointing_device.drag(start_x, start_y, stop_x, stop_y)

    @autopilot.logging.log_action(logger.info)
    def swipe_up(self):
        self.shown.wait_for(True)
        x, y, width, height = self.globalRect
        start_y = height
        stop_y = y
        start_x = stop_x = x + width // 2
        self.pointing_device.drag(start_x, start_y, stop_x, stop_y)

    @autopilot.logging.log_action(logger.info)
    def tap(self):
        """Tap the tick button to complete this step."""
        self.shown.wait_for(True)
        button = self.wait_select_single(objectName="tick")
        self.pointing_device.click_object(button)
