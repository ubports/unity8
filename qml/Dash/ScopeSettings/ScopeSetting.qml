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

import QtQuick 2.4
import Ubuntu.Components 1.3

/*! Interface for settings widgets. */

Item {
    //! The ScopeStyle component.
    property var scopeStyle: null

    //! Variable used to contain widget's data
    property var widgetData: null

    /*! \brief This signal should be emitted when a setting action was updated.
     *
     *  \param value the new setting value.
     */
    signal updated(var value)

    /*! \brief This signal should be emitted when widget gains the focus
     *  and input method popups.
     *  And preview widget should reposition in visible area to avoid
     *  keyboard appears over the widget.
     *
     *  \param item, id of specified item which is needed to reposition.
     */
    signal makeSureVisible(var item)

    //! \internal
    readonly property real settingMargins: units.gu(2)
}
