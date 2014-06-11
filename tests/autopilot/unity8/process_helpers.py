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

import logging
import subprocess
import sys

# This has to work in both python 3 (ap 1.5) and py2 (ap legacy 1.4.1) so we
# pick the correct location in each case. Remove the py2 branch once we no
# longer need to support python 2.
if sys.version >= '3':
    from autopilot.exceptions import ProcessSearchError
else:
    from autopilot.introspection import ProcessSearchError
from autopilot.introspection import get_proxy_object_for_existing_process

from unity8.shell import emulators
from unity8.shell.emulators import main_window as main_window_emulator

logger = logging.getLogger(__name__)


class CannotAccessUnity(Exception):
    pass


def lock_unity(unity_proxy_obj=None):
    """Helper function that attempts to lock the unity greeter."""
    import evdev, time
    uinput = evdev.UInput(name='unity8-autopilot-power-button',
                          devnode='/dev/autopilot-uinput')
    # One press and release to turn screen off (locking unity)
    uinput.write(evdev.ecodes.EV_KEY, evdev.ecodes.KEY_POWER, 1)
    uinput.write(evdev.ecodes.EV_KEY, evdev.ecodes.KEY_POWER, 0)
    uinput.syn()
    time.sleep(1)
    # And another press and release to turn screen back on
    uinput.write(evdev.ecodes.EV_KEY, evdev.ecodes.KEY_POWER, 1)
    uinput.write(evdev.ecodes.EV_KEY, evdev.ecodes.KEY_POWER, 0)
    uinput.syn()


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
        command = ['/sbin/initctl', 'start', 'unity8'] + list(args)
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
