/*
 * Copyright (C) 2019 The UBports Foundation
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

pragma Singleton
import QtQuick 2.0

Item {
    id: root

    property int targetBuildNumber: 0
    property bool checkingForUpdates: false
    property bool updateAvailable: false

    signal updateDownloaded()
    signal applyUpdate()
    signal checkForUpdate()
}
