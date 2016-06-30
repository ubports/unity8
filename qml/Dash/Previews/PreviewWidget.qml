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

/*! Interface for preview widgets. */

Item {
    //! The widget identifier
    property string widgetId

    //! Variable used to contain widget's data
    property var widgetData

    //! The ScopeStyle component.
    property var scopeStyle: null

    //! Should the widget show in expanded mode (For those that support it)
    property bool expanded: true

    //! Should the orientation be locked
    property bool orientationLock: false

    //! Set margins width.
    property real widgetMargins: units.gu(1)

    /// The parent (vertical) flickable this widget is in (if any)
    property var parentFlickable: null

    /*! \brief This signal should be emitted when a preview action was triggered.
     *
     *  \param widgetId, actionId Respective identifiers from widgetData.
     *  \param data Optional widget-specific data sent to the scope.
     */
    signal triggered(string widgetId, string actionId, var data)

    /*! \brief This signal should be emitted when widget gains the focus
     *  and input method popups.
     *  And preview widget should reposition in visible area to avoid
     *  keyboard appears over the widget.
     *
     *  \param item, id of specified item which is needed to reposition.
     */
    signal makeSureVisible(var item)

    objectName: widgetId
}
