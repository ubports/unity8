/*
 * Copyright 2013 Canonical Ltd.
 *
 * This program is free software; you can redistribute it and/or modify
 * it under the terms of the GNU Lesser General Public License as published by
 * the Free Software Foundation; version 3.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU Lesser General Public License for more details.
 *
 * You should have received a copy of the GNU Lesser General Public License
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.
 *
 * Authors:
 *      Renato Araujo Oliveira Filho <renato@canonical.com>
 *      Nick Dedekind <nick.dedekind@canonical.com>
 */

import QtQuick 2.4
import Ubuntu.Components 1.3
import ".."
import "../.."

Page {
    id: root
    property variant indicatorProperties

    header: PageHeader {
        title: indicatorProperties && indicatorProperties.title ? indicatorProperties.title :
                                                                  indicatorProperties && indicatorProperties.accessibleName ? indicatorProperties.accessibleName
                                                                                                                            : identifier
    }

    anchors.fill: parent

    ListItem {
        color: theme.palette.highlighted.background
        id: visualCheckItem

        anchors {
            top: header.bottom
            left: parent.left
            right: parent.right
        }

        height: selectorLayout.height
        onClicked: visualCheck.checked = !visualCheck.checked

        ListItemLayout {
            id: selectorLayout
            title.text: "Enable Visual Representation"

            Switch {
                id: visualCheck
                checked: true
                SlotsLayout.position: SlotsLayout.Trailing
            }
        }
    }

    Loader {
        id: pageLoader
        objectName: "pageLoader"
        clip:true
        asynchronous: true

        anchors {
            top: visualCheckItem.bottom
            left: parent.left
            right: parent.right
            bottom: buttons.top
            topMargin: units.gu(2)
            bottomMargin: units.gu(2)
        }
        sourceComponent: visualCheck.checked ? page : tree

        Component {
            id: page
            PanelMenuPage {
                objectName: model.identifier + "-page"
                submenuIndex: 0

                menuModel: delegate.menuModel

                factory: IndicatorMenuItemFactory {
                    indicator: model.identifier
                    rootModel: delegate.menuModel
                }

                IndicatorDelegate {
                    id: delegate
                    busName: indicatorProperties.busName
                    actionsObjectPath: indicatorProperties.actionsObjectPath
                    menuObjectPath: indicatorProperties.menuObjectPath
                }
            }
        }
        Component {
            id: tree
            IndicatorsTree {
                identifier: model.identifier
                busName: indicatorProperties.busName
                actionsObjectPath: indicatorProperties.actionsObjectPath
                menuObjectPath: indicatorProperties.menuObjectPath
            }
        }
    }

    Item {
        id: buttons
        anchors {
            left: parent.left
            right: parent.right
            bottom: parent.bottom
            margins: units.gu(1)
        }
        height: childrenRect.height
    }
}
