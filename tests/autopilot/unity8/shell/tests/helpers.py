# -*- Mode: Python; coding: utf-8; indent-tabs-mode: nil; tab-width: 4 -*-
# Copyright 2013 Canonical
#
# This program is free software: you can redistribute it and/or modify it
# under the terms of the GNU General Public License version 3, as published
# by the Free Software Foundation.

from autopilot.matchers import Eventually
from testtools.matchers import Equals, NotEquals
from functools import wraps
import os.path

from unity8 import get_lib_path


import logging

logger = logging.getLogger(__name__)


def with_lightdm_mock(mock_type):
    """A simple decorator that sets up the LightDM mock for a single test."""
    def with_lightdm_mock_internal(fn):
        @wraps(fn)
        def wrapper(*args, **kwargs):
            logger.info("Setting up LightDM mock type '%s'", mock_type)
            lib_path = get_lib_path()
            new_ld_library_path = os.path.join(
                lib_path,
                "qml/mocks/LightDM/",
                mock_type
            )
            if not os.path.exists(new_ld_library_path):
                raise RuntimeError(
                    "LightDM mock '%s' does not exist." % mock_type
                )

            logger.info("New library path: %s", new_ld_library_path)
            args[0].patch_environment('LD_LIBRARY_PATH', new_ld_library_path)
            return fn(*args, **kwargs)
        return wrapper
    return with_lightdm_mock_internal
