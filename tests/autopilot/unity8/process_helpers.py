# -*- Mode: Python; coding: utf-8; indent-tabs-mode: nil; tab-width: 4 -*-
#
# Unity Autopilot Utilities
# Copyright (C) 2013, 2014, 2015 Canonical
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

import ubuntuuitoolkit
from autopilot.introspection import get_proxy_object_for_existing_process

from unity8 import greeter


logger = logging.getLogger(__name__)


class JobError(Exception):
    pass


class CannotAccessUnity(Exception):
    pass


def unlock_unity():
    """Helper function that attempts to unlock the unity greeter.

    """
    greeter.wait_for_greeter()
    greeter.hide_greeter_with_dbus()
    greeter.wait_for_greeter_gone()


def lock_unity():
    """Helper function that attempts to lock unity greeter.

    """
    greeter.show_greeter_with_dbus()
    greeter.wait_for_greeter()


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
        stop_job('unity8')

    pid = start_job('unity8', *args)
    return _get_unity_proxy_object(pid)


def start_job(name, *args):
    """Start a job.

    :param str name: The name of the job.
    :param args: The arguments to be used when starting the job.
    :return: The process id of the started job.
    :raises CalledProcessError: if the job failed to start.

    """
    logger.info('Starting job {} with arguments {}.'.format(name, args))
    command = ['/sbin/initctl', 'start', name] + list(args)
    try:
        output = subprocess.check_output(
            command,
            stderr=subprocess.STDOUT,
            universal_newlines=True,
        )
        logger.info(output)
        pid = get_job_pid(name)
    except subprocess.CalledProcessError as e:
        e.args += ('Failed to start {}: {}.'.format(name, e.output),)
        raise
    else:
        return pid


def get_job_pid(name):
    """Return the process id of a running job.

    :param str name: The name of the job.
    :raises JobError: if the job is not running.

    """
    status = get_job_status(name)
    if "start/" not in status:
        raise JobError('{} is not in the running state.'.format(name))
    return int(status.split()[-1])


def get_job_status(name):
    """Return the status of a job.

    :param str name: The name of the job.
    :raises JobError: if it's not possible to get the status of the job.

    """
    try:
        return subprocess.check_output([
            '/sbin/initctl',
            'status',
            name
        ], universal_newlines=True)
    except subprocess.CalledProcessError as error:
        raise JobError(
            "Unable to get {}'s status: {}".format(name, error)
        )


def stop_job(name):
    """Stop a job.

    :param str name: The name of the job.
    :raises CalledProcessError: if the job failed to stop.

    """
    logger.info('Stoping job {}.'.format(name))
    command = ['/sbin/initctl', 'stop', name]
    try:
        output = subprocess.check_output(
            command,
            stderr=subprocess.STDOUT,
            universal_newlines=True,
        )
        logger.info(output)
    except subprocess.CalledProcessError as e:
        e.args += ('Failed to stop {}: {}.'.format(name, e.output),)
        raise


def is_job_running(name):
    """Return True if the job is running. Otherwise, False.

    :param str name: The name of the job.
    :raises JobError: if it's not possible to get the status of the job.

    """
    return 'start/' in get_job_status(name)


def _get_unity_status():
    try:
        return get_job_status('unity8')
    except JobError as error:
        raise CannotAccessUnity(str(error))


def _get_unity_pid():
    try:
        return get_job_pid('unity8')
    except JobError as error:
        raise CannotAccessUnity(str(error))


def _get_unity_proxy_object(pid):
    return get_proxy_object_for_existing_process(
        pid=pid,
        emulator_base=ubuntuuitoolkit.UbuntuUIToolkitCustomProxyObjectBase
    )
