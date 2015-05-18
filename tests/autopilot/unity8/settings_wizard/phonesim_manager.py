#!/usr/bin/python -tt

# -*- Mode: Python; coding: utf-8; indent-tabs-mode: nil; tab-width: 4 -*-
#
# Unity Indicators Autopilot Test Suite
# Copyright (C) 2014 Canonical
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


from __future__ import absolute_import

import dbus
import subprocess
from time import sleep


class PhonesimManager(object):

    def __init__(self, sims, exe=None):
        if exe is None:
            self.phonesim_exe = '/usr/bin/ofono-phonesim'
        else:
            self.phonesim_exe = exe
        self.sims = sims
        self.sim_processes = {}
        self.system_bus = dbus.SystemBus()
        self.ofono = self.system_bus.get_object('org.ofono', '/')
        self.phonesim_manager = dbus.Interface(
            self.ofono,
            'org.ofono.phonesim.Manager'
        )

    def start_phonesim_processes(self):
        for simname, simport, conffile in self.sims:
            cmd = ['/usr/bin/xvfb-run', '-a', self.phonesim_exe, '-p', str(simport), conffile]
            p = subprocess.Popen(cmd)
            self.sim_processes[simname] = p
        # give the processes some time to start
        sleep(1)

    def shutdown(self):
        for p in self.sim_processes.values():
            p.kill()
        self.sim_processes = {}

    def reset_ofono(self):
        self.phonesim_manager.Reset()

    def remove_all_ofono(self):
        self.phonesim_manager.RemoveAll()

    def add_ofono(self, name):
        for simname, simport, _ in self.sims:
            if name == simname:
                self.phonesim_manager.Add(simname, '127.0.0.1', str(simport))
                return
        raise RuntimeError('Tried to add unknown modem %s.' % name)

    def power_on(self, sim_name):
        sim = self.system_bus.get_object('org.ofono', '/'+sim_name)
        modem = dbus.Interface(sim, dbus_interface='org.ofono.Modem')
        modem.SetProperty('Powered', True)
        sleep(1)

    def power_off(self, sim_name):
        sim = self.system_bus.get_object('org.ofono', '/'+sim_name)
        modem = dbus.Interface(sim, dbus_interface='org.ofono.Modem')
        modem.SetProperty('Powered', False)
        sleep(1)

    def get_required_pin(self, sim_name):
        sim = self.system_bus.get_object('org.ofono', '/'+sim_name)
        interface = dbus.Interface(sim, dbus_interface='org.ofono.SimManager')
        return str(interface.GetProperties()['PinRequired'])


if __name__ == '__main__':
    sims = [('sim1', 12345, '/usr/share/phonesim/default.xml'),
            ('sim2', 12346, '/usr/share/phonesim/default.xml')]
    m = PhonesimManager(sims)
    m.start_phonesim_processes()
    import pdb
    pdb.set_trace()
    m.shutdown()
