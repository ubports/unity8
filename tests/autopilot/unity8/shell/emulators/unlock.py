import subprocess

from autopilot.introspection import (
    get_proxy_object_for_existing_process,
    ProcessSearchError,
)
from unity8.shell.emulators.main_window import MainWindow
from unity8.shell.emulators import UnityEmulatorBase


class CannotAccessUnity(Exception):
    pass


def unlock_unity():
    """Helper function that attempts to unlock the unity greeter.

    :raises: RuntimeError if the greeter attempts and fails to be unlocked.

    :raises: RuntimeWarning when the greeter cannot be found because it is
      already unlocked.
    :raises: CannotAccessUnity if unity is not introspectable or cannot be
      found on dbus.
    :raises: CannotAccessUnity if unity's upstart status is not "start" or the
      upstart job cannot be found at all.

    """
    pid = _get_unity_pid()
    try:
        unity = get_proxy_object_for_existing_process(
            pid=pid,
            emulator_base=UnityEmulatorBase,
        )
        main_window = MainWindow(unity)

        greeter = main_window.get_greeter()
        if greeter is None:
            raise RuntimeWarning("Greeter appears to be already unlocked.")
        greeter.swipe()
    except ProcessSearchError as e:
        raise CannotAccessUnity(
            "Cannot introspect unity, make sure that it has been started "
            "with 'testability' (%s)" % e.message
        )


def _get_unity_pid():
    try:
        status = subprocess.check_output([
            'initctl',
            'status',
            'unity8'
        ])
        if not "start/" in status:
            raise CannotAccessUnity("Unity is not in the running state.")
        return int(status.split()[-1])
    except subprocess.CalledProcessError as e:
        raise CannotAccessUnity("Unable to get unity's status: %s" % e.message)
