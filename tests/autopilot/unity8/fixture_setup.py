# -*- Mode: Python; coding: utf-8; indent-tabs-mode: nil; tab-width: 4 -*-
#
# Unity Autopilot Test Suite
# Copyright (C) 2014, 2015 Canonical
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

import os
import subprocess
import threading
import fixtures
import logging

import ubuntuuitoolkit
from autopilot import introspection
from autopilot.matchers import Eventually
from testtools.matchers import Equals
from ubuntuuitoolkit import fixture_setup

from unity8 import (
    get_binary_path,
    get_mocks_library_path,
    get_default_extra_mock_libraries,
    get_data_dirs,
    sensors,
    shell,
    process_helpers
)


logger = logging.getLogger(__name__)


class LaunchUnityWithFakeSensors(fixtures.Fixture):

    """Fixture to launch Unity8 with an injectable sensors backend.

    :ivar unity_proxy: The Autopilot proxy object for the Unity shell.

    """

    unity_proxy = None
    main_win = None

    def setUp(self):
        """Restart Unity8 with testability and create sensors."""
        super().setUp()
        self.useFixture(
            fixture_setup.InitctlEnvironmentVariable(
                UBUNTU_PLATFORM_API_TEST_OVERRIDE='sensors'))

        self.addCleanup(process_helpers.stop_job, 'unity8')
        restart_thread = threading.Thread(
            target=self._restart_unity_with_testability)
        restart_thread.start()

        self._create_sensors()

        restart_thread.join()
        self.fake_sensors = sensors.FakePlatformSensors()

    def _get_lightdm_mock_path(self):
        lib_path = get_mocks_library_path()
        lightdm_mock_path = os.path.abspath(
            os.path.join(lib_path, "LightDM" ,"IntegratedLightDM", "liblightdm")
        )

        if not os.path.exists(lightdm_mock_path):
            raise RuntimeError(
                "LightDM mock does not exist at path {}.".
                format(lightdm_mock_path)
            )
        return lightdm_mock_path

    def _get_qml_import_path_with_mock(self):
        """Return the QML2_IMPORT_PATH value with the mock path prepended."""
        qml_import_path = [get_mocks_library_path()]
        if os.getenv('QML2_IMPORT_PATH') is not None:
            qml_import_path.append(os.getenv('QML2_IMPORT_PATH'))

        qml_import_path = ':'.join(qml_import_path)
        return qml_import_path

    def _restart_unity_with_testability(self):
        _environment = {}

        data_dirs = get_data_dirs(True)
        if data_dirs is not None:
            _environment['XDG_DATA_DIRS'] = data_dirs

        _environment['QML2_IMPORT_PATH'] = (
            self._get_qml_import_path_with_mock()
        )

        new_ld_library_path = [
            get_default_extra_mock_libraries(),
            self._get_lightdm_mock_path()
        ]
        if os.getenv('LD_LIBRARY_PATH') is not None:
            new_ld_library_path.append(os.getenv('LD_LIBRARY_PATH'))
        new_ld_library_path = ':'.join(new_ld_library_path)
        _environment['LD_LIBRARY_PATH'] = new_ld_library_path

        # FIXME: we shouldn't be doing this
        # $MIR_SOCKET, fallback to $XDG_RUNTIME_DIR/mir_socket and
        # /tmp/mir_socket as last resort
        try:
            os.unlink(
                os.getenv('MIR_SOCKET',
                          os.path.join(os.getenv('XDG_RUNTIME_DIR', "/tmp"),
                                       "mir_socket")))
        except OSError:
            pass
        try:
            os.unlink("/tmp/mir_socket")
        except OSError:
            pass

        binary_arg = "BINARY=%s" % get_binary_path()
        env_args = ["%s=%s" % (k, v) for k, v in _environment.items()]
        args = [binary_arg] + env_args
        self.unity_proxy = process_helpers.restart_unity_with_testability(
            *args)
        self.main_win = self.unity_proxy.select_single(shell.ShellView)

    def _create_sensors(self):
        # Wait for unity to start running.
        Eventually(Equals(True)).match(
            lambda: process_helpers.is_job_running('unity8'))

        # Wait for the sensors fifo file to be created.
        fifo_path = '/tmp/sensor-fifo-{0}'.format(
            process_helpers._get_unity_pid())
        Eventually(Equals(True)).match(
            lambda: os.path.exists(fifo_path))

        with open(fifo_path, 'w') as fifo:
            fifo.write('create accel 0 1000 0.1\n')
            fifo.write('create light 0 10 1\n')
            fifo.write('create proximity\n')


class RestartUnityWithTestability(fixtures.Fixture):

    """Fixture to launch Unity8 with testability.

    :ivar unity_proxy: The Autopilot proxy object for the Unity shell.

    """

    unity_proxy = None

    def __init__(self, binary_path, variables):
        """Initialize the fixture instance.

        :param str binary_path: The path to the Dash app binary.
        :param cli_arguments: The arguments to pass when launching the
        :param variables: The variables to use when launching the app.
        :type variables: A dictionary.

        """
        super().__init__()
        self.binary_path = binary_path
        self.variables = variables

    def setUp(self):
        """Restart unity with testability when the fixture is used."""
        super().setUp()
        self.addCleanup(self.stop_unity)
        self.restart_unity()

    def restart_unity(self):
        self.restart_unity_with_testability()

    def restart_unity_with_testability(self):
        self._unlink_mir_socket()

        binary_arg = 'BINARY={}'.format(self.binary_path)
        variable_args = [
            '{}={}'.format(key, value) for key, value in self.variables.items()
        ]
        all_args = [binary_arg] + variable_args

        self.unity_proxy = process_helpers.restart_unity_with_testability(
            *all_args)

    def _unlink_mir_socket(self):
        # FIXME: we shouldn't be doing this
        # $MIR_SOCKET, fallback to $XDG_RUNTIME_DIR/mir_socket and
        # /tmp/mir_socket as last resort
        try:
            os.unlink(
                os.getenv('MIR_SOCKET',
                          os.path.join(os.getenv('XDG_RUNTIME_DIR', "/tmp"),
                                       "mir_socket")))
        except OSError:
            pass
        try:
            os.unlink("/tmp/mir_socket")
        except OSError:
            pass

    def stop_unity(self):
        process_helpers.stop_job('unity8')


class LaunchDashApp(fixtures.Fixture):

    """Fixture to launch the Dash app."""

    def __init__(self, binary_path, variables):
        """Initialize an instance.

        :param str binary_path: The path to the Dash app binary.
        :param variables: The variables to use when launching the app.
        :type variables: A dictionary.

        """
        super().__init__()
        self.binary_path = binary_path
        self.variables = variables

    def setUp(self):
        """Launch the dash app when the fixture is used."""
        super().setUp()
        self.addCleanup(self.stop_application)
        self.application_proxy = self.launch_application()

    def launch_application(self):
        binary_arg = 'BINARY={}'.format(self.binary_path)
        testability_arg = 'QT_LOAD_TESTABILITY={}'.format(1)
        env_args = [
            '{}={}'.format(key, value) for key, value in self.variables.items()
        ]
        all_args = [binary_arg, testability_arg] + env_args

        pid = process_helpers.start_job('unity8-dash', *all_args)
        return introspection.get_proxy_object_for_existing_process(
            pid=pid,
            emulator_base=ubuntuuitoolkit.UbuntuUIToolkitCustomProxyObjectBase
        )

    def stop_application(self):
        process_helpers.stop_job('unity8-dash')


class DisplayRotationLock(fixtures.Fixture):

    def __init__(self, enable):
        super().__init__()
        self.enable = enable

    def setUp(self):
        super().setUp()
        original_state = self._is_rotation_lock_enabled()
        if self.enable != original_state:
            self.addCleanup(self._set_rotation_lock, original_state)
            self._set_rotation_lock(self.enable)

    def _is_rotation_lock_enabled(self):
        command = [
            'gsettings', 'get',
            'com.ubuntu.touch.system',
            'rotation-lock'
        ]
        output = subprocess.check_output(command, universal_newlines=True)
        return True if output.count('true') else False

    def _set_rotation_lock(self, value):
        value_string = 'true' if value else 'false'
        command = [
            'gsettings', 'set',
            'com.ubuntu.touch.system',
            'rotation-lock', value_string
        ]
        subprocess.check_output(command)


class LaunchMockIndicatorService(fixtures.Fixture):

    """Fixture to launch the indicator test service."""

    def __init__(self, action_delay, ensure_not_running=True):
        """Initialize an instance.

        :param action_delay: The delay to use when activating actions.
          Measured in milliseconds. Value of -1 will result in infinite delay.
        :type action_delay: An integer.
        :param boolean ensure_not_running: Make sure service is not running

        """
        super(LaunchMockIndicatorService, self).__init__()
        self.action_delay = action_delay
        self.ensure_not_running = ensure_not_running

    def setUp(self):
        super().setUp()
        if self.ensure_not_running:
            self.ensure_service_not_running()
        self.addCleanup(self.stop_service)
        self.application_proxy = self.launch_service()

    def launch_service(self):
        logger.info("Starting unity-mock-indicator-service")
        binary_path = get_binary_path('unity-mock-indicator-service')
        binary_arg = 'BINARY={}'.format(binary_path)
        env_args = 'ARGS=-t {}'.format(self.action_delay)
        all_args = [binary_arg, env_args]
        process_helpers.start_job('unity-mock-indicator-service', *all_args)

    def stop_service(self):
        logger.info("Stopping unity-mock-indicator-service")
        process_helpers.stop_job('unity-mock-indicator-service')

    def ensure_service_not_running(self):
        if process_helpers.is_job_running('unity-mock-indicator-service'):
            self.stop_service()
