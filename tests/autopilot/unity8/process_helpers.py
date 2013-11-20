# -*- Mode: Python; coding: utf-8; indent-tabs-mode: nil; tab-width: 4 -*-
#
# Unity Autopilot Utilities
# Copyright (C) 2013 Canonical
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

from autopilot.introspection import (
    get_proxy_object_for_existing_process,
    ProcessSearchError,
)
import logging
import subprocess
from unity8.shell.emulators import UnityEmulatorBase
from unity8.shell.emulators.main_window import MainWindow

logger = logging.getLogger(__name__)


class CannotAccessUnity(Exception):
    pass


def restart_unity_with_testability(*args):
    """Restarts (or starts) unity with testability enabled.

    Passes *args arguments to the launched process.

    """
    args += ("QT_LOAD_TESTABILITY=1",)
    return restart_unity(*args)


def restart_unity(*args):
    """Restarts (or starts) unity8 using the provided arguments.

    Passes *args arguments to the launched process.

    :raises subprocess.CalledProcessError: if unable to stop or start the
      unity8 upstart job.

    """
    status = _get_unity_status()
    if "start/" in status:
        try:
            output = subprocess.check_output(['initctl', 'stop', 'unity8'])
            logger.info(output)
        except subprocess.CalledProcessError as e:
            e.args += (
                "Failed to stop running instance of unity8: %s" % e.output,
            )
            raise

    try:
        command = ['initctl', 'start', 'unity8'] + list(args)
        output = subprocess.check_output(
            command,
            stderr=subprocess.STDOUT,
            universal_newlines=True,
        )
        logger.info(output)
        pid = _get_unity_pid()
    except subprocess.CalledProcessError as e:
        e.args += ("Failed to start unity8: %s" % e.output,)
        raise
    else:
        return _get_unity_proxy_object(pid)


def _get_unity_status():
    try:
        return subprocess.check_output([
            'initctl',
            'status',
            'unity8'
        ])
    except subprocess.CalledProcessError as e:
        raise CannotAccessUnity("Unable to get unity's status: %s" % str(e))


def _get_unity_pid():
    status = _get_unity_status()
    if not "start/" in status:
        raise CannotAccessUnity("Unity is not in the running state.")
    return int(status.split()[-1])


def _get_unity_proxy_object(pid):
    return get_proxy_object_for_existing_process(
        pid=pid,
        emulator_base=UnityEmulatorBase,
    )
