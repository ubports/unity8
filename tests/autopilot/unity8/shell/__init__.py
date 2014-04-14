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

"""unity shell autopilot tests and emulators - sub level package."""

from time import sleep
from functools import wraps
from gi.repository import Notify

import logging

logger = logging.getLogger(__name__)


def with_lightdm_mock(mock_type):
    """A simple decorator that sets up the LightDM mock for a single test."""
    def with_lightdm_mock_internal(fn):
        @wraps(fn)
        def wrapper(*args, **kwargs):
            tests_self = args[0]
            tests_self.patch_lightdm_mock(mock_type)
            return fn(*args, **kwargs)
        return wrapper
    return with_lightdm_mock_internal


def disable_qml_mocking(fn):
    """Simple decorator that disables the QML mocks from being loaded."""
    @wraps(fn)
    def wrapper(*args, **kwargs):
        tests_self = args[0]
        tests_self._qml_mock_enabled = False
        return fn(*args, **kwargs)
    return wrapper


class DragMixin(object):
    def _drag(self, x1, y1, x2, y2):
        # XXX This ugly code is here just temporarily, waiting for drag
        # improvements to land on autopilot so we don't have to access device
        # private internal attributes. --elopio - 2014-02-12
        cur_x = x1
        cur_y = y1
        dx = 1.0 * (x2 - x1) / 100
        dy = 1.0 * (y2 - y1) / 100
        for i in range(0, 100):
            try:
                self.touch._finger_move(int(cur_x), int(cur_y))
            except AttributeError:
                self.touch._device.finger_move(int(cur_x), int(cur_y))
            sleep(0.002)
            cur_x += dx
            cur_y += dy
        try:
            self.touch._finger_move(int(x2), int(y2))
        except AttributeError:
            self.touch._device.finger_move(int(x2), int(y2))


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
