# -*- Mode: Python; coding: utf-8; indent-tabs-mode: nil; tab-width: 4 -*-
#
# Unity Autopilot Test Suite
# Copyright (C) 2012, 2013, 2014, 2015 Canonical
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

"""unity autopilot tests and helpers - top level package."""
import os
import os.path
import subprocess
import sysconfig


class UnityException(Exception):
    """Exception raised when there is an error with the Unity test helpers."""


def running_installed_tests():
    binary_path = get_binary_path()
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
        binary_path = get_binary_path()
        lib_path = os.path.dirname(binary_path)
    return lib_path


def get_default_extra_mock_libraries():
    mocks_path = get_mocks_library_path()
    return os.path.join(mocks_path, 'libusermetrics')


def get_mocks_library_path():
    if running_installed_tests():
        mock_path = "qml/mocks/"
    else:
        mock_path = os.path.join(
            "../lib/",
            sysconfig.get_config_var('MULTIARCH'),
            "unity8/qml/mocks/"
        )
    lib_path = get_lib_path()
    ld_library_path = os.path.abspath(
        os.path.join(
            lib_path,
            mock_path,
        )
    )

    if not os.path.exists(ld_library_path):
        raise RuntimeError(
            "Expected library path does not exists: %s." % (ld_library_path)
        )
    return ld_library_path


def get_binary_path(binary="unity8"):
    """Return the path to the specified binary."""
    binary_path = os.path.abspath(
        os.path.join(
            os.path.dirname(__file__),
            "../../../builddir/install/bin/%s" % binary
        )
    )
    if not os.path.exists(binary_path):
        try:
            binary_path = subprocess.check_output(
                ['which', binary],
                universal_newlines=True,
            ).strip()
        except subprocess.CalledProcessError as e:
            raise RuntimeError("Unable to locate %s binary: %r" % (binary, e))
    return binary_path


def get_data_dirs(data_dirs_mock_enabled=True):
    """Prepend a mock data path to XDG_DATA_DIRS."""
    data_dirs = _get_xdg_env_path()
    if data_dirs_mock_enabled:
        mock_data_path = _get_full_mock_data_path()
        if os.path.exists(mock_data_path):
            if data_dirs is not None:
                data_dirs = '{0}:{1}'.format(mock_data_path, data_dirs)
            else:
                data_dirs = mock_data_path
    return data_dirs


def _get_full_mock_data_path():
    if running_installed_tests():
        data_path = "/usr/share/unity8/mocks/data"
    else:
        data_path = "../../mocks/data"
    return os.path.abspath(
        os.path.join(
            os.path.dirname(__file__),
            data_path
        )
    )


def _get_xdg_env_path():
    path = os.getenv("XDG_DATA_DIRS")
    if path is None:
        path = _get_xdg_upstart_env()
    return path


def _get_xdg_upstart_env():
    try:
        return subprocess.check_output([
            "/sbin/initctl",
            "get-env",
            "--global",
            "XDG_DATA_DIRS"
        ], universal_newlines=True).rstrip()
    except subprocess.CalledProcessError:
        return None


def get_grid_size():
    grid_size = os.getenv('GRID_UNIT_PX')
    if grid_size is None:
        raise RuntimeError(
            "Environment variable GRID_UNIT_PX has not been set."
        )
    return int(grid_size)
