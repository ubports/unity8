#!/usr/bin/python3
# -*- Mode: Python; coding: utf-8; indent-tabs-mode: nil; tab-width: 4 -*-
#
# Lomiri Autopilot Test Suite
# Copyright (C) 2012, 2013, 2015 Canonical Ltd.
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


from distutils.core import setup
from setuptools import find_packages

setup(
    name='lomiri',
    version='8.0',
    description='Lomiri autopilot tests.',
    url='https://launchpad.net/lomiri',
    license='GPLv3',
    packages=find_packages(),
)
