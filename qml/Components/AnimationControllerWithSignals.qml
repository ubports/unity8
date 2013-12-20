/*
 * Copyright (C) 2013 Canonical, Ltd.
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

AnimationController {
    signal animationCompletedAtBeginning()
    signal animationCompletedAtEnd()
    readonly property bool completed: progress == 1.0 || progress == 0.0
    property bool completing: false

    function __completeAtBeginning() {
        completing = false;
        animationCompletedAtBeginning();
    }

    function __completeAtEnd() {
        completing = false;
        animationCompletedAtEnd();
    }

    function completeToBeginningWithSignal() {
        if (progress == 0.0) {
            __completeAtBeginning()
        } else {
            completing = true;
            completeToBeginning();
        }
    }

    function completeToEndWithSignal() {
        if (progress == 1.0) {
            __completeAtEnd()
        } else {
            completing = true;
            completeToEnd();
        }
    }

    onProgressChanged: {
        if (!completing) {
            return;
        }

        if (progress == 0.0) {
            __completeAtBeginning()
        } else if (progress == 1.0) {
            __completeAtEnd()
        }
    }
}
