# -*- Mode: Python; coding: utf-8; indent-tabs-mode: nil; tab-width: 4 -*-
# Copyright 2013 Canonical
#
# This program is free software: you can redistribute it and/or modify it
# under the terms of the GNU General Public License version 3, as published
# by the Free Software Foundation.

from autopilot.introspection.dbus import DBusIntrospectionObject
from autopilot.input import Mouse, Touch, Pointer
from autopilot.platform import model

from time import sleep

from autopilot.introspection.dbus import IntrospectableObjectMetaclass

class IndicatorsIntrospectionObject(DBusIntrospectionObject):

    """A common class that provides introspection and other helpers to indictors."""

    if model() == 'Desktop':
        scenarios = [
        ('with mouse', dict(input_device_class=Mouse)),
        ]
    else:
        scenarios = [
        ('with touch', dict(input_device_class=Touch)),
        ]

    def setUp(self):
        self.pointing_device = Pointer(self.input_device_class.create())
        super(IndicatorsTestCase, self).setUp()
