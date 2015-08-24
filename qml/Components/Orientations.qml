/*
 * Copyright 2015 Canonical Ltd.
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

import QtQuick 2.3

QtObject {
    // Just because "native" is a reserved keyword :(
    property int native_: Qt.PortraitOrientation

    property int primary: Qt.PortraitOrientation

    property int landscape: Qt.LandscapeOrientation
    property int invertedLandscape: Qt.InvertedLandscapeOrientation
    property int portrait: Qt.PortraitOrientation
    property int invertedPortrait: Qt.InvertedPortraitOrientation
}
