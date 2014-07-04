/*
 * Copyright (C) 2013 Canonical, Ltd.
 *
 * Authors:
 *   Daniel d'Andrada <daniel.dandrada@canonical.com>
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

import QtQuick 2.0
import Ubuntu.Settings.Menus 0.1 as Menus

QtObject {
    property int busType
    property string busName
    property string objectPath
    function start() {}
    function action(actionName) {
        switch (actionName) {
            case "transfer-state.queued":
                return {
                    'valid': true,
                    'state': {
                        'state': Menus.TransferState.Queued,
                        'percent': 0.0
                    }
            }
            case "transfer-state.running":
                return {
                    'valid': true,
                    'state': {
                        'state': Menus.TransferState.Running,
                        'seconds-left': 100,
                        'percent': 0.1
                    }
            }
            case "transfer-state.paused":
                return {
                    'valid': true,
                    'state': {
                        'state': Menus.TransferState.Paused,
                        'seconds-left': 100,
                        'percent': 0.5
                    }
            }
            case "transfer-state.cancelled":
                return {
                    'valid': true,
                    'state': {
                        'state': Menus.TransferState.Canceled,
                        'percent': 0.4
                    }
            }
            case "transfer-state.finished": return {
                    'valid': true,
                    'state': {
                        'state': Menus.TransferState.Finished,
                        'seconds-left': 0,
                        'percent': 1.0
                    }
            }
            case "transfer-state.error":
                return {
                    'valid': true,
                    'state': {
                        'state': Menus.TransferState.Error,
                        'seconds-left': 100,
                        'percent': 0.0
                    }
            }
            default:
                break;
        }

        return null;
    }
}
