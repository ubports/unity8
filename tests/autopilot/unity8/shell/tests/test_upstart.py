# -*- Mode: Python; coding: utf-8; indent-tabs-mode: nil; tab-width: 4 -*-
#
# Unity Autopilot Test Suite
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

"""Tests for upstart integration."""

import os
import stat
import signal
import subprocess
import time

import fixtures
import ubuntuuitoolkit
from autopilot.matchers import Eventually
from autopilot.introspection import get_proxy_object_for_existing_process
from testtools.matchers import Equals, MismatchError
from ubuntuuitoolkit import ubuntu_scenarios

from unity8 import get_binary_path
from unity8.shell.tests import UnityTestCase

import logging

logger = logging.getLogger(__name__)


class UpstartIntegrationTests(UnityTestCase):

    scenarios = ubuntu_scenarios.get_device_simulation_scenarios()

    def _get_status(self):
        pid, status = os.waitpid(
            self.process.pid, os.WUNTRACED | os.WCONTINUED | os.WNOHANG)
        logger.debug(
            "Got status: {0}; stopped: {1}; continued: {2}".format(
                status, os.WIFSTOPPED(status), os.WIFCONTINUED(status)))
        return status

    def _launch_unity(self):
        self.patch_environment("QT_LOAD_TESTABILITY", "1")

        try:
            host_socket = os.getenv("MIR_SOCKET", "/run/mir_socket")
            if stat.S_ISSOCK(os.stat(host_socket).st_mode):
                self.patch_environment("MIR_SERVER_HOST_SOCKET",
                                       host_socket)
                socket = os.path.join(os.getenv("XDG_RUNTIME_DIR", "/tmp"),
                                      "mir_socket")
                self.patch_environment("MIR_SERVER_FILE", socket)
        except OSError:
            pass

        self.process = subprocess.Popen(
            [get_binary_path()] + self.unity_geometry_args)

        def ensure_stopped():
            self.process.terminate()
            for i in range(10):
                try:
                    self._get_status()
                except OSError:
                    break
                else:
                    time.sleep(1)
            try:
                self._get_status()
            except OSError:
                pass
            else:
                self.process.kill()

            self.process.wait()

        self.addCleanup(ensure_stopped)

    def _set_proxy(self):
        proxy_base = ubuntuuitoolkit.UbuntuUIToolkitCustomProxyObjectBase
        super()._set_proxy(
            get_proxy_object_for_existing_process(
                pid=self.process.pid,
                emulator_base=proxy_base))

    def test_no_sigstop(self):
        self.useFixture(
            fixtures.EnvironmentVariable(
                'UNITY_MIR_EMITS_SIGSTOP', newvalue=None))
        self._launch_unity()

        try:
            self.assertThat(
                lambda: os.WIFSTOPPED(self._get_status()),
                Eventually(Equals(True)))
        except MismatchError:
            pass
        else:
            self.process.send_signal(signal.SIGCONT)
            self.fail('Unity8 raised SIGSTOP')

        self._set_proxy()

        logger.debug("Unity started, waiting for it to be ready.")
        self.wait_for_unity()
        logger.debug("Unity loaded and ready.")

    def test_expect_sigstop(self):
        self.useFixture(
            fixtures.EnvironmentVariable('UNITY_MIR_EMITS_SIGSTOP', '1'))
        self._launch_unity()
        self.assertThat(
            lambda: os.WIFSTOPPED(self._get_status()),
            Eventually(Equals(True)), "Unity8 should raise SIGSTOP when ready")

        self.process.send_signal(signal.SIGCONT)
        self.assertThat(
            lambda: os.WIFCONTINUED(self._get_status()),
            Eventually(Equals(True)), "Unity8 should have resumed")

        logger.debug("Unity started, waiting for it to be ready.")
        self._set_proxy()
        self.wait_for_unity()
        logger.debug("Unity loaded and ready.")
