# -*- Mode: Python; coding: utf-8; indent-tabs-mode: nil; tab-width: 4 -*-
# Copyright 2013 Canonical
#
# This program is free software: you can redistribute it and/or modify it
# under the terms of the GNU General Public License version 3, as published
# by the Free Software Foundation.

"""unity8 autopilot tests and emulators - top level package."""
import os.path
import subprocess
import sysconfig


def running_installed_tests():
    binary_path = get_unity8_binary_path()
    return binary_path.startswith('/usr')


def get_lib_path():
    """Return the library path to use in this test run."""
    if running_installed_tests():
        lib_path = os.path.join(
            "/usr/lib/",
            sysconfig.get_config_var('MULTIARCH'),
            "unity8"
            )
    else:
        binary_path = get_unity8_binary_path()
        lib_path = os.path.dirname(binary_path)
    return lib_path


def get_unity8_binary_path():
    """Return the path to the unity8 binary."""
    binary_path = os.path.abspath(
        os.path.join(
            os.path.dirname(__file__),
            "../../../builddir/unity8"
            )
        )
    if not os.path.exists(binary_path):
        try:
            binary_path = subprocess.check_output(['which', 'unity8']).strip()
        except subprocess.CalledProcessError as e:
            raise RuntimeError("Unable to locate unity8 binary: %r" % e)
    return binary_path

