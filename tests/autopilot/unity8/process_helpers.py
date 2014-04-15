# -*- Mode: Python; coding: utf-8; indent-tabs-mode: nil; tab-width: 4 -*-
#
# Unity Autopilot Utilities
# Copyright (C) 2013, 2014 Canonical
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
from unity8.shell import emulators
from unity8.shell.emulators import main_window as main_window_emulator

logger = logging.getLogger(__name__)


class CannotAccessUnity(Exception):
    pass


def unlock_unity(unity_proxy_obj=None):
    """Helper function that attempts to unlock the unity greeter.

    If unity_proxy_object is None create a proxy object by querying for the
    running unity process.
    Otherwise re-use the passed proxy object.

    :raises RuntimeError: if the greeter attempts and fails to be unlocked.

    :raises RuntimeWarning: when the greeter cannot be found because it is
      already unlocked.
    :raises CannotAccessUnity: if unity is not introspectable or cannot be
      found on dbus.
    :raises CannotAccessUnity: if unity's upstart status is not "start" or the
      upstart job cannot be found at all.

    """
    if unity_proxy_obj is None:
        try:
            pid = _get_unity_pid()
            unity = _get_unity_proxy_object(pid)
            main_window = unity.select_single(main_window_emulator.QQuickView)
        except ProcessSearchError as e:
            raise CannotAccessUnity(
                "Cannot introspect unity, make sure that it has been started "
                "with testability. Perhaps use the function "
                "'restart_unity_with_testability' this module provides."
                "(%s)"
                % str(e)
            )
    else:
        main_window = unity_proxy_obj.select_single(
            main_window_emulator.QQuickView)

    greeter = main_window.get_greeter()
    if greeter.created == False:
        raise RuntimeWarning("Greeter appears to be already unlocked.")

    # Because of potential input jerkiness under heavy load,
    # retry unlocking the greeter two times.
    # https://bugs.launchpad.net/ubuntu/+bug/1260113

    retries = 3
    while retries > 0:
        try:
            greeter.swipe()
        except AssertionError:
            retries -= 1
            if retries == 0:
                raise
            logger.info("Failed to unlock greeter, trying again...")
        else:
            logger.info("Greeter unlocked, continuing.")
            break


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
            output = subprocess.check_output(
                ['/sbin/initctl', 'stop', 'unity8'])
            logger.info(output)
        except subprocess.CalledProcessError as e:
            e.args += (
                "Failed to stop running instance of unity8: %s" % e.output,
            )
            raise

    try:
        command = ['/sbin/initctl', 'start', 'unity8', 'LC_ALL=C'] + list(args)
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
            '/sbin/initctl',
            'status',
            'unity8'
        ], universal_newlines=True)
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
        emulator_base=emulators.UnityEmulatorBase,
    )
