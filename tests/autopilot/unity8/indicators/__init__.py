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
#
# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>.

from autopilot import input
from unity8.shell import emulators
from unity8.shell.emulators import main_window
import ubuntuuitoolkit


class IndicatorsMenu(emulators.UnityEmulatorBase):

    """Autopilot helper for the IndicatorPage component."""

    def open(self):
        widget = self.select_single(
            'IndicatorItem', objectName='indicator-sound-panelItem')
        start_x, start_y = input.get_center_point(widget)
        end_x = start_x
        end_y = self.globalRect.y + self.openedHeight
        self.pointing_device.drag(start_x, start_y, end_x, end_y)
        self.fullyOpened.wait_for(True)

    def open_rotation_indicator(self):
        self.open()
        indicators_bar_flickable = self.select_single(
            'IndicatorsBar').select_single(
                main_window.QQuickFlickable, objectName='flickable')
        indicators_bar_flickable.swipe_to_x_end()
        indicator_rotation_icon = self.select_single(
            objectName='indicator-rotation-lock-panelItem')
        self.pointing_device.click_object(indicator_rotation_icon)
        self.fullyOpened.wait_for(True)
        return DisplayIndicator(
            self.select_single(
                'IndicatorPage', objectName='indicator-rotation-lock-page'))


class DisplayIndicator(emulators.UnityEmulatorBase):

    def __init__(self, subject):
        self.__subject = subject

    def __getattr__(self, name):
        return getattr(self.__subject, name)

    def lock_rotation(self):
        """Toggles the rotation lock indicator to locked.

        Swipes open indicator-display and ensures that rotation lock is toggled
        to 'On'.

        """
        switcher = self.select_single(
            ubuntuuitoolkit.CheckBox, objectName='switcher')
        switcher.check()

    def unlock_rotation(self):
        """Toggles the rotation lock indicator to unlocked.

        Swipes open indicator-display and ensures that rotation lock is toggled
        to 'Off'.

        """
        switcher = self.select_single(
            ubuntuuitoolkit.CheckBox, objectName='switcher')
        switcher.uncheck()
