#!/usr/bin/python

# -*- Mode: Python; coding: utf-8; indent-tabs-mode: nil; tab-width: 4 -*-
# Copyright 2013 Canonical
#
# This program is free software: you can redistribute it and/or modify it
# under the terms of the GNU General Public License version 3, as published
# by the Free Software Foundation.


from distutils.core import setup
from setuptools import find_packages

setup(
    name='unity',
    version='8.0',
    description='Unity 8 autopilot tests.',
    url='https://launchpad.net/unity',
    license='GPLv3',
    packages=find_packages(),
)
