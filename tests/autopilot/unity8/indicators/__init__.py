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


class IndicatorPage(ubuntuuitoolkit.UbuntuUIToolkitCustomProxyObjectBase):

    """Autopilot helper for the IndicatorPage component."""

    # XXX Because of https://bugs.launchpad.net/autopilot-qt/+bug/1341671
    # we need to make sure it does not match in any selection.
    # --elopio - 2015-01-20

    @classmethod
    def validate_dbus_object(cls, path, state):
        return False


class Indicator():

    def __init__(self, main_window, name):
        self._main_window = main_window
        self._name = name

    def is_indicator_icon_visible(self):
        panel_item = self._main_window.wait_select_single(
            objectName=self._name+'-panelItem')
        return panel_item.indicatorVisible

    def open(self):
        """Open the indicator page.

        :return: The custom proxy object for the indicator page.

        """
        if self.is_indicator_icon_visible():
            return self._main_window.open_indicator_page(self._name)
        else:
            return self._open_indicator_with_icon_not_visible()

    def _open_indicator_with_icon_not_visible(self):
        # Open any displayed indicator.
        self._main_window.open_indicator_page('indicator-datetime')
        self._make_indicator_icon_visible()
        indicator_rotation_icon = self._main_window.select_single(
            objectName=self._name+'-panelItem')
        self._main_window.pointing_device.click_object(indicator_rotation_icon)
        return self._main_window.wait_select_single(
            objectName=self._name+'-page')

    def _make_indicator_icon_visible(self):
        indicators_bar = self._main_window.select_single('IndicatorsBar')
        indicators_bar_flickable = indicators_bar.select_single(
            ubuntuuitoolkit.QQuickFlickable, objectName='flickable')
        self._swipe_flickable_to_x_end(indicators_bar_flickable)

    def _swipe_flickable_to_x_end(self, flickable):
        # XXX this should be implemented as a general horizontal swiping in
        # the toolkit custom proxy object. -- elopio - 2015-01-20
        if not flickable.atXEnd:
            flickable.interactive.wait_for(True)
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

    def close(self):
        """Close the indicator page."""
        self._main_window.close_indicator_page()


class DisplayIndicator(Indicator):

    def __init__(self, main_window):
        super(DisplayIndicator, self).__init__(main_window,
                                               'indicator-rotation-lock')
        self._main_window = main_window


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
        """Toggle the rotation lock indicator to locked."""
        switcher = self._get_switcher()
        switcher.check()
        switcher.checked.wait_for(True)

    def _get_switcher(self):
        return self.select_single(
            ubuntuuitoolkit.CheckBox, objectName='switcher')

    def unlock_rotation(self):
        """Toggle the rotation lock indicator to unlocked."""
        switcher = self._get_switcher()
        switcher.uncheck()
        switcher.checked.wait_for(False)


class TestIndicator(Indicator):

    def __init__(self, main_window):
        super(TestIndicator, self).__init__(main_window, 'indicator-mock')
        self._main_window = main_window


class TestIndicatorPage(IndicatorPage):

    """Autopilot helper for the mock indicator page."""

    @classmethod
    def validate_dbus_object(cls, path, state):
        name = introspection.get_classname_from_path(path)
        if name == b'IndicatorPage':
            if state['objectName'][1] == 'indicator-mock-page':
                return True
        return False

    def get_switcher(self):
        return self.select_single(
            ubuntuuitoolkit.CheckBox, objectName='switcher')

    def get_switch_menu(self):
        return self.select_single(
            'SwitchMenu', objectName='indicator.action.switch')

    def get_slider(self):
        return self.select_single(objectName='slider')

    def get_slider_menu(self):
        return self.select_single(objectName='indicator.action.slider')


class Slider(ubuntuuitoolkit.UbuntuUIToolkitCustomProxyObjectBase):

    """Autopilot helper for the Slider component."""

    # XXX Because of https://bugs.launchpad.net/autopilot-qt/+bug/1341671
    # we need to make sure it does not match in any selection.
    # --elopio - 2015-01-20

    @classmethod
    def validate_dbus_object(cls, path, state):
        name = introspection.get_classname_from_path(path)
        if name == b'Slider':
            return True
        return False

    def slide_left(self, timeout=10):
        x, y, width, height = self.globalRect

        rate = 5
        start_x = x + width/2
        start_y = stop_y = y + height/2
        stop_x = x

        self.pointing_device.drag(start_x, start_y, stop_x, stop_y, rate)
        self.value.wait_for(self.minimumValue, timeout)

    def slide_right(self, timeout=10):
        x, y, width, height = self.globalRect

        rate = 5
        start_x = x + width/2
        start_y = stop_y = y + height/2
        stop_x = x + width

        self.pointing_device.drag(start_x, start_y, stop_x, stop_y, rate)
        self.value.wait_for(self.maximumValue, timeout)
