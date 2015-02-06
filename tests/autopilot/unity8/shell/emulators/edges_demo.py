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


class RightEdgeDemoOverlay(
        ubuntuuitoolkit.UbuntuUIToolkitCustomProxyObjectBase):

    @classmethod
    def validate_dbus_object(cls, path, state):
        name = introspection.get_classname_from_path(path)
        if name == b'EdgeDemoOverlay':
            if state['edge'][1] == 'right':
                return True
        return False

    @autopilot.logging.log_action(logger.info)
    def swipe(self):
        """Swipe to the left to complete this demo step."""
        x, y, width, height = self.globalRect
        start_x = x + width
        stop_x = x
        start_y = stop_y = y + height // 2
        self.pointing_device.drag(start_x, start_y, stop_x, stop_y)
        return self.get_root_instance().wait_select_single(
            edge='top', active=True)


class TopEdgeDemoOverlay(
        ubuntuuitoolkit.UbuntuUIToolkitCustomProxyObjectBase):

    @classmethod
    def validate_dbus_object(cls, path, state):
        name = introspection.get_classname_from_path(path)
        if name == b'EdgeDemoOverlay':
            if state['edge'][1] == 'top':
                return True
        return False

    @autopilot.logging.log_action(logger.info)
    def swipe(self):
        """Swipe to the bottom to complete this demo step."""
        x, y, width, height = self.globalRect
        start_x = stop_x = x + width // 2
        start_y = y
        stop_y = y + height
        self.pointing_device.drag(start_x, start_y, stop_x, stop_y)
        return self.get_root_instance().wait_select_single(
            edge='bottom', active=True)


class BottomEdgeDemoOverlay(
        ubuntuuitoolkit.UbuntuUIToolkitCustomProxyObjectBase):

    @classmethod
    def validate_dbus_object(cls, path, state):
        name = introspection.get_classname_from_path(path)
        if name == b'EdgeDemoOverlay':
            if state['edge'][1] == 'bottom':
                return True
        return False

    @autopilot.logging.log_action(logger.info)
    def swipe(self):
        """Swipe to the top to complete this demo step."""
        x, y, width, height = self.globalRect
        start_x = stop_x = x + width // 2
        start_y = y + height
        stop_y = y
        self.pointing_device.drag(start_x, start_y, stop_x, stop_y)
        return self.get_root_instance().wait_select_single(
            edge='left', active=True)


class LeftEdgeDemoOverlay(
        ubuntuuitoolkit.UbuntuUIToolkitCustomProxyObjectBase):

    @classmethod
    def validate_dbus_object(cls, path, state):
        name = introspection.get_classname_from_path(path)
        if name == b'EdgeDemoOverlay':
            if state['edge'][1] == 'left':
                return True
        return False

    @autopilot.logging.log_action(logger.info)
    def swipe(self):
        """Swipe to the right to complete this demo step."""
        x, y, width, height = self.globalRect
        start_x = x
        stop_x = x + width
        start_y = stop_y = y + height // 2
        self.pointing_device.drag(start_x, start_y, stop_x, stop_y)
        return self.get_root_instance().wait_select_single(
            edge='none', active=True)


class FinalEdgeDemoOverlay(
        ubuntuuitoolkit.UbuntuUIToolkitCustomProxyObjectBase):

    @classmethod
    def validate_dbus_object(cls, path, state):
        name = introspection.get_classname_from_path(path)
        if name == b'EdgeDemoOverlay':
            if state['edge'][1] == 'none':
                return True
        return False

    @autopilot.logging.log_action(logger.info)
    def tap_to_start(self):
        """Tap to finish the demo and start using the Ubuntu Touch."""
        time.sleep(1)
        self.pointing_device.click_object(self)
        self.shown.wait_for(False)
