# -*- Mode: Python; coding: utf-8; indent-tabs-mode: nil; tab-width: 4 -*-
#
# Unity Autopilot Test Suite
# Copyright (C) 2012-2015 Canonical
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

"""unity shell autopilot tests and helpers - sub level package."""

import logging
from functools import wraps

import ubuntuuitoolkit
from autopilot import logging as autopilot_logging
from autopilot import input
from gi.repository import Notify

from unity8 import (
    greeter,
    launcher as launcher_helpers
)


logger = logging.getLogger(__name__)


def disable_qml_mocking(fn):
    """Simple decorator that disables the QML mocks from being loaded."""
    @wraps(fn)
    def wrapper(*args, **kwargs):
        tests_self = args[0]
        tests_self._qml_mock_enabled = False
        return fn(*args, **kwargs)
    return wrapper


def create_ephemeral_notification(
    summary='',
    body='',
    icon=None,
    hints=[],
    urgency='NORMAL'
):
    """Create an ephemeral (non-interactive) notification

    :param summary: Summary text for the notification
    :param body: Body text to display in the notification
    :param icon: Path string to the icon to use
    :param hint_strings: List of tuples containing the 'name' and value
        for setting the hint strings for the notification
    :param urgency: Urgency string for the noticiation, either: 'LOW',
        'NORMAL', 'CRITICAL'
    """
    Notify.init('Unity8')

    logger.info(
        "Creating ephemeral: summary(%s), body(%s), urgency(%r) "
        "and Icon(%s)",
        summary,
        body,
        urgency,
        icon
    )

    notification = Notify.Notification.new(summary, body, icon)

    for hint in hints:
        key, value = hint
        notification.set_hint_string(key, value)
        logger.info("Adding hint to notification: (%s, %s)", key, value)
    notification.set_urgency(_get_urgency(urgency))

    return notification


def _get_urgency(urgency):
    """Translates urgency string to enum."""
    _urgency_enums = {'LOW': Notify.Urgency.LOW,
                      'NORMAL': Notify.Urgency.NORMAL,
                      'CRITICAL': Notify.Urgency.CRITICAL}
    return _urgency_enums.get(urgency.upper())


class ShellView(ubuntuuitoolkit.UbuntuUIToolkitCustomProxyObjectBase):
    """An helper class that makes it easy to interact with the shell"""

    def get_greeter(self):
        return self.select_single(greeter.Greeter)

    def get_login_loader(self):
        return self.select_single("QQuickLoader", objectName="loginLoader")

    def get_login_list(self):
        return self.select_single("LoginList")

    def get_bottombar(self):
        return self.select_single("Bottombar")

    def get_pinPadLoader(self):
        return self.select_single(
            "QQuickLoader",
            objectName="pinPadLoader"
        )

    def get_lockscreen(self):
        return self.select_single("Lockscreen")

    def get_pinentryField(self):
        return self.select_single(objectName="pinentryField")

    def _get_indicator_panel_item(self, indicator_name):
        return self.select_single(
            'IndicatorItem',
            objectName=indicator_name+'-panelItem'
        )

    def _get_indicator_page(self, indicator_name):
        return self.select_single(
            'IndicatorPage',
            objectName=indicator_name+'-page'
        )

    @autopilot_logging.log_action(logger.info)
    def open_indicator_page(self, indicator_name):
        """Swipe to open the indicator, wait until it's open.

        :returns: The indicator page.
        """
        widget = self._get_indicator_panel_item(indicator_name)
        start_x, start_y = input.get_center_point(widget)
        end_x = start_x
        end_y = self.height
        self.pointing_device.drag(start_x, start_y, end_x, end_y)
        self.wait_select_single('IndicatorsMenu', fullyOpened=True)
        return self._get_indicator_page(indicator_name)

    @autopilot_logging.log_action(logger.info)
    def close_indicator_page(self):
        """Swipe to close the opened indicator, wait until it's closed."""
        indicators_menu = self.wait_select_single('IndicatorsMenu')
        end_x, end_y = input.get_center_point(indicators_menu)
        start_x = end_x
        start_y = self.height
        self.pointing_device.drag(start_x, start_y, end_x, end_y)
        indicators_menu.fullyClosed.wait_for(True)

    @autopilot_logging.log_action(logger.info)
    def show_dash_swiping(self):
        """Show the dash swiping from the left."""
        x, y, width, height = self._get_shell().globalRect
        start_x = x
        end_x = x + width
        start_y = end_y = y + height // 2

        self.pointing_device.drag(start_x, start_y, end_x, end_y)
        self.get_current_focused_app_id().wait_for('unity8-dash')

    def _get_shell(self):
        return self.select_single('Shell')

    def get_current_focused_app_id(self):
        """Return the id of the focused application."""
        return self._get_shell().focusedApplicationId

    @autopilot_logging.log_action(logger.info)
    def show_dash_from_launcher(self):
        """Open the dash clicking the dash icon on the launcher."""
        launcher = self.open_launcher()
        launcher.click_dash_icon()
        self.get_current_focused_app_id().wait_for('unity8-dash')
        launcher.shown.wait_for(False)

    @autopilot_logging.log_action(logger.info)
    def open_launcher(self):
        launcher = self._get_launcher()
        launcher.show()
        return launcher

    def _get_launcher(self):
        return self.select_single(launcher_helpers.Launcher)

    def is_launcher_open(self):
        return self._get_launcher().shown

    @autopilot_logging.log_action(logger.info)
    def launch_application(self, application_name):
        """Launch an application.

        :parameter application_name: The name of the application to launch.

        """
        launcher = self.open_launcher()
        launcher.click_application_launcher_icon(application_name)
        self.get_current_focused_app_id().wait_for(application_name)
        launcher.shown.wait_for(False)

    def enter_pin_code(self, code):
        """Enter code 'code' into the single-pin lightdm pincode entry screen.

        :param code: must be a string of numeric characters.
        :raises: TypeError if code is not a string.
        :raises: ValueError if code contains non-numeric characters.

        """
        if not isinstance(code, str):
            raise TypeError(
                "'code' parameter must be a string, not %r."
                % type(code)
            )
        for num in code:
            if not num.isdigit():
                raise ValueError(
                    "'code' parameter contains non-numeric characters."
                )
            self.pointing_device.click_object(
                self._get_pinpad_button(int(num)))

    def _get_pinpad_button(self, button_id):
        return self.select_single(
            'PinPadButton',
            objectName='pinPadButton{}'.format(button_id)
        )

    def get_shell_orientation_angle(self):
        return self._get_shell().orientationAngle

    def get_shell_orientation(self):
        return self._get_shell().orientation

    def get_shell_primary_orientation(self):
        return self._get_shell().primaryOrientation

    def get_shell_native_orientation(self):
        return self._get_shell().nativeOrientation

    @autopilot_logging.log_action(logger.info)
    def wait_for_notification(self):
        """Wait for a notification dialog to appear.

        :return: An object for the notification dialog data.
        :raise StateNotFoundError: if the timeout expires when the
        notification has not appeared.

        """
        notify_list = self.select_single('Notifications',
                                         objectName='notificationList')
        visible_notification = notify_list.wait_select_single('Notification',
                                                              visible=True)
        return {'summary': visible_notification.summary,
                'body': visible_notification.body,
                'iconSource': visible_notification.iconSource}
