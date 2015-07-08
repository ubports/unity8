# -*- Mode: Python; coding: utf-8; indent-tabs-mode: nil; tab-width: 4 -*-
#
# Unity Autopilot Test Suite
# Copyright (C) 2015 Canonical
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

"""Control module for event injection to the fake/test platform sensors."""

from unity8 import process_helpers


class FakePlatformSensors:

    def __init__(self, pid=None):
        self.pid = pid or process_helpers._get_unity_pid()

    def set_orientation(self, action):
        if action == 'top_up':
            with open("/tmp/sensor-fifo-{0}".format(self.pid), "w") as fifo:
                fifo.write("70 accel -10.050858 -0.598550 0.756568\n")
                fifo.write("70 accel -9.797073 -0.555455 1.019930\n")
                fifo.write("70 accel -10.141838 -0.770933 0.632069\n")
                fifo.write("70 accel -12.057199 -1.259350 1.690306\n")
                fifo.write("70 accel -19.282900 -3.926491 3.098097\n")
                fifo.write("70 accel -14.480132 -14.269443 1.216254\n")
                fifo.write("70 accel 16.419436 4.242526 -7.714118\n")
                fifo.write("70 accel 5.583278 8.279149 -1.848324\n")
                fifo.write("70 accel 1.422156 8.547300 0.416591\n")
                fifo.write("70 accel 4.357447 9.988609 -0.110133\n")
                fifo.write("70 accel 0.699107 9.840169 0.756568\n")
                fifo.write("70 accel 1.364695 9.844957 -0.287304\n")
                fifo.flush()
        elif action == 'top_down':
            with open("/tmp/sensor-fifo-{0}".format(self.pid), "w") as fifo:
                fifo.write("70 accel -10.050858 -0.598550 0.756568\n")
                fifo.write("70 accel 9.538500 -0.603339 1.292869\n")
                fifo.write("70 accel 9.485827 -0.636858 1.422156\n")
                fifo.write("70 accel 9.677363 -0.402226 1.374272\n")
                fifo.write("70 accel 9.303867 -0.507571 1.283292\n")
                fifo.write("70 accel 8.604761 -1.015141 1.436521\n")
                fifo.write("70 accel 7.580042 -2.001553 0.521936\n")
                fifo.write("70 accel 7.503428 -4.247314 0.502782\n")
                fifo.write("70 accel 7.067683 -7.240066 0.842759\n")
                fifo.write("70 accel 6.488286 -9.873688 -0.541090\n")
                fifo.write("70 accel 6.229713 -9.241618 -1.048660\n")
                fifo.write("70 accel 4.046201 -9.198523 -0.057461\n")
                fifo.write("70 accel 2.398990 -9.629479 0.957681\n")
                fifo.write("70 accel 1.632846 -9.361329 -0.311246\n")
                fifo.write("70 accel -0.181959 -9.696517 -0.301669\n")
                fifo.flush()
        elif action == 'left_up':
            with open("/tmp/sensor-fifo-{0}".format(self.pid), "w") as fifo:
                fifo.write("70 accel -10.050858 -0.598550 0.756568\n")
                fifo.write("70 accel 0.196325 9.878476 0.948104\n")
                fifo.write("70 accel 0.258574 9.955091 1.091756\n")
                fifo.write("70 accel 0.287304 10.041282 1.134852\n")
                fifo.write("70 accel 1.537078 10.553641 1.561020\n")
                fifo.write("70 accel 8.130709 10.093954 2.561796\n")
                fifo.write("70 accel -0.229843 5.348647 1.723825\n")
                fifo.write("70 accel -9.916783 0.488417 -3.418920\n")
                fifo.write("70 accel -13.417107 -0.416591 -2.360683\n")
                fifo.write("70 accel -13.872005 -2.049437 -0.574608\n")
                fifo.flush()
        elif action == 'right_up':
            with open("/tmp/sensor-fifo-{0}".format(self.pid), "w") as fifo:
                fifo.write("70 accel -10.050858 -0.598550 0.756568\n")
                fifo.write("70 accel -4.550858 -0.598550 0.856568\n")
                fifo.write("70 accel -0.799663 9.988609 1.197101\n")
                fifo.write("70 accel -0.861913 9.864111 1.066701\n")
                fifo.write("70 accel -0.861913 9.864111 0.866701\n")
                fifo.write("70 accel -1.776498 9.830592 1.273715\n")
                fifo.write("70 accel -2.376498 9.830592 1.273715\n")
                fifo.write("70 accel -13.158532 2.217031 1.091756\n")
                fifo.write("70 accel 5.056554 1.067814 0.799663\n")
                fifo.write("70 accel 5.056554 1.767814 0.799663\n")
                fifo.write("70 accel 14.882358 2.896984 1.221043\n")
                fifo.write("70 accel 9.466674 -0.363919 -1.029507\n")
                fifo.write("70 accel 11.253524 -0.186748 -0.311246\n")
                fifo.write("70 accel 12.253524 -0.186748 -0.311246\n")
                fifo.flush()
