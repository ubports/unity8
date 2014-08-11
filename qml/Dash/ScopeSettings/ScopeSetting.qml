/*
 * Copyright (C) 2014 Canonical, Ltd.
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

import QtQuick 2.2
import Ubuntu.Components 1.1

/*! Interface for settings widgets. */

Item {
    //! The ScopeStyle component.
    property var scopeStyle: null

    //! Variable used to contain widget's data
    property var widgetData: null

    readonly property real __margins: units.gu(2)

    /*! \brief This signal should be emitted when a setting action was updated.
     *
     *  \param value the new setting value.
     */
    signal updated(var value)
}
