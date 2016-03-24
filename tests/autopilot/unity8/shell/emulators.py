# -*- Mode: Python; coding: utf-8; indent-tabs-mode: nil; tab-width: 4 -*-
#
# Unity Autopilot Test Suite
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
#

"""Emulators was the old name for the custom proxy objects."""

import logging


logger = logging.getLogger(__name__)


logger.warning(
    'The unity8.shell.emulators module is deprecated. Import the autopilot '
    'helpers from the top-level unity8 module.')


__all__ = [
    'create_interactive_notification',
    'dash',
    'greeter',
    'launcher',
    'main_window',
    'UnityEmulatorException',
]


from unity8 import (
    greeter,
    dash,
    launcher,
    shell as main_window,
    UnityException as UnityEmulatorException
)
from unity8.shell import create_interactive_notification
