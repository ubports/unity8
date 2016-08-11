/*
 * Copyright (C) 2015 Canonical, Ltd.
 *
 * This program is free software; you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation; version 3.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.
 */

import QtQuick 2.4
import Ubuntu.Components 1.3

Item {
    BorderImage {
        anchors {
            fill: parent
            topMargin: -units.gu(1)
            leftMargin: -units.gu(1.5)
            rightMargin: -units.gu(1.5)
            bottomMargin: -units.gu(1.5)
        }
        source: "../Stages/graphics/dropshadow2gu.sci"
        opacity: 0.35
    }

    UbuntuShape {
        anchors.fill: parent
        aspect: UbuntuShape.Flat
        backgroundColor: theme.palette.normal.raised
    }
}
