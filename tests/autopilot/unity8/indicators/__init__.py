# -*- Mode: Python; coding: utf-8; indent-tabs-mode: nil; tab-width: 4 -*-
#
# Unity Indicators Autopilot Test Suite
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
# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>.

import ubuntuuitoolkit
from autopilot import introspection

from unity8.shell import emulators


class IndicatorPage(emulators.UnityEmulatorBase):

    """Autopilot helper for the IndicatorPage component."""

    # XXX Because of https://bugs.launchpad.net/autopilot-qt/+bug/1341671
    # we need to make sure it does not match in any selection.

    @classmethod
    def validate_dbus_object(cls, path, state):
        return False


class DisplayIndicator(object):

    def __init__(self, main_window):
        self._main_window = main_window

    def open(self):
        """Open the display indicator page.

        :return: The custom proxy object for the display indicator page.

        """
        # TODO open the indicator directly if it is displayed in the menu.
        # open any displayed indicator.
        self._main_window.open_indicator_page('indicator-datetime')
        self._make_indicator_icon_visible()
        indicator_rotation_icon = self._main_window.select_single(
            objectName='indicator-rotation-lock-panelItem')
        self._main_window.pointing_device.click_object(indicator_rotation_icon)
        indicators_menu = self._main_window.select_single('IndicatorsMenu')
        indicators_menu.fullyOpened.wait_for(True)
        return self._main_window.select_single(
            objectName='indicator-rotation-lock-page')

    def _make_indicator_icon_visible(self):
        indicators_bar_flickable = self._main_window.select_single(
            'IndicatorsBar').select_single(
                ubuntuuitoolkit.QQuickFlickable, objectName='flickable')
        self._swipe_flickable_to_x_end(indicators_bar_flickable)

    def _swipe_flickable_to_x_end(self, flickable):
        # XXX this should be implemented as a general horizontal swiping in
        # the toolkit custom proxy object.
        if not flickable.atXEnd:
            while not flickable.atXEnd:
                start_y = stop_y = (
                    flickable.globalRect.y +
                    (flickable.globalRect.height // 2))
                # We can't start the swipe from the border because it would
                # open the launcher
                start_x = flickable.globalRect.x + 45
                stop_x = (
                    flickable.globalRect.x + flickable.globalRect.width - 5)
                flickable.pointing_device.drag(
                    start_x, start_y, stop_x, stop_y)
                flickable.dragging.wait_for(False)
                flickable.moving.wait_for(False)


class DisplayIndicatorPage(IndicatorPage):

    """Autopilot helper for the display indicator page."""

    @classmethod
    def validate_dbus_object(cls, path, state):
        name = introspection.get_classname_from_path(path)
        if name == b'IndicatorPage':
            if state['objectName'][1] == 'indicator-rotation-lock-page':
                return True
        return False

    def lock_rotation(self):
        """Toggles the rotation lock indicator to locked."""
        switcher = self._get_switcher()
        switcher.check()
        switcher.checked.wait_for(True)

    def _get_switcher(self):
        return self.select_single(
            ubuntuuitoolkit.CheckBox, objectName='switcher')

    def unlock_rotation(self):
        """Toggles the rotation lock indicator to unlocked."""
        switcher = self._get_switcher()
        switcher.uncheck()
        switcher.checked.wait_for(False)
