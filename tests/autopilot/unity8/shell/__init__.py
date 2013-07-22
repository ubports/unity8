# -*- Mode: Python; coding: utf-8; indent-tabs-mode: nil; tab-width: 4 -*-
#
# Unity8 Autopilot Test Suite
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

"""unity8 shell autopilot tests and emulators - sub level package."""

from functools import wraps
import logging
import os.path

from unity8 import get_mocks_library_path


logger = logging.getLogger(__name__)


def with_lightdm_mock(mock_type):
    """A simple decorator that sets up the LightDM mock for a single test."""
    def with_lightdm_mock_internal(fn):
        @wraps(fn)
        def wrapper(*args, **kwargs):
            logger.info("Setting up LightDM mock type '%s'", mock_type)
            new_ld_library_path = _get_ld_library_path(mock_type)
            logger.info("New library path: %s", new_ld_library_path)
            tests_self = args[0]
            tests_self.patch_environment(
                'LD_LIBRARY_PATH',
                new_ld_library_path
            )
            return fn(*args, **kwargs)
        return wrapper
    return with_lightdm_mock_internal


def _get_ld_library_path(mock_type):
    lib_path = get_mocks_library_path()
    new_ld_library_path = os.path.abspath(
        os.path.join(lib_path, "LightDM", mock_type)
    )

    if not os.path.exists(new_ld_library_path):
        raise RuntimeError(
            "LightDM mock '%s' does not exist at path '%s'."
            % (mock_type, new_ld_library_path)
        )
    return new_ld_library_path
