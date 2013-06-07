# -*- Mode: Python; coding: utf-8; indent-tabs-mode: nil; tab-width: 4 -*-
# Copyright 2013 Canonical
#
# This program is free software: you can redistribute it and/or modify it
# under the terms of the GNU General Public License version 3, as published
# by the Free Software Foundation.

from indicators_client.emulators import IndicatorsEmulatorBase

class SwitchMenu(IndicatorsEmulatorBase):
    """A switch menu control."""

    def setUp(self):
        print "PLOP"
        super(IndicatorsEmulatorBase, self).setUp()

    def switch(self):
        self.plop()
        ab_switch = self.select_single("CheckBox");
        self.assertThat(ab_switch, NotEquals(None))

        self.pointing_device.move_to_object(ab_switch)
        self.pointing_device.click()

class SliderMenu(IndicatorsEmulatorBase):
    """A slider menu control."""

    def set_value(self, new_value):
        brightness_slider = self.select_single("Slider");
        self.assertThat(brightness_slider, NotEquals(None))

        self.pointing_device.move_to_object(brightness_slider)

        old_ab_value = brightness_slider.value
        pixel_ratio = brightness_slider.width / (brightness_slider.maximumValue - brightness_slider.minimumValue)
        print pixel_ratio

        while True:

            pixels_to_move = int(pixel_ratio * (new_value - old_ab_value) / 15)
            if pixels_to_move == 0:
                break;
            print pixels_to_move

            self.pointing_device.drag(self.pointing_device.x, self.pointing_device.y, self.pointing_device.x + pixels_to_move, self.pointing_device.y)

            old_ab_value = brightness_slider.value