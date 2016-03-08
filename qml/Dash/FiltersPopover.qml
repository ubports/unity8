/*
 * Copyright (C) 2013-2015 Canonical, Ltd.
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
import Ubuntu.Components.Popups 1.3
import "Filters" as Filters

Popover {
    id: root
    objectName: "filtersPopover"

    Flickable {
        id: flickable
        anchors {
            top: parent.top
            left: parent.left
            right: parent.right
        }
        height: {
            // Popover doesn't like being 75% or bigger than the screen (counting the "empty" part on top)
            var posToRootParent = flickable.mapToItem(null, 0, 0).y;
            var threeQuartersParent = root.parent.height * 3 / 4 - posToRootParent - 1;
            var parentAndKeyboard = root.parent.height - posToRootParent - (Qt.inputMethod.visible ? Qt.inputMethod.keyboardRectangle.height + units.gu(3) : 0)
            return Math.min(parentAndKeyboard, Math.min(threeQuartersParent, column.height));
        }
        clip: true
        contentHeight: column.height
        contentWidth: width

        Column {
            id: column
            width: parent.width

            Item {
                width: parent.width
                height: resetLabel.height + units.gu(3)

                Label {
                    anchors {
                        left: parent.left
                        right: resetLabel.left
                        margins: units.gu(2)
                        verticalCenter: parent.verticalCenter
                    }
                    text: i18n.tr("Refine your results")
                }
                Label {
                    id: resetLabel
                    anchors {
                        right: parent.right
                        rightMargin: units.gu(2)
                        verticalCenter: parent.verticalCenter
                    }
                    text: i18n.tr("Reset")

                    AbstractButton {
                        anchors {
                            fill: parent
                            rightMargin: units.gu(-2)
                            leftMargin: units.gu(-2)
                            topMargin: units.gu(-1)
                            bottomMargin: units.gu(-1)
                        }
                        onClicked: {
                            scopeView.scope.resetFilters();
                        }
                    }
                }
            }

            Repeater {
                model: scopeView.scope.filters

                delegate: Filters.FilterWidgetFactory {
                    width: parent.width

                    widgetId: id
                    widgetType: type
                    widgetData: filter
                }
            }
        }
    }
}
