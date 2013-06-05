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
import Ubuntu.Components 0.1
import "../../Components"
import "../../Components/ListItems" as ListItems
import ".."
import "Preview"

DashPreview {
    id: preview

    property var model: undefined

    title: (model && model.displayName) ? model.displayName : ""
    url: (model && model.avatar) ? model.avatar : ""
    previewWidthRatio: 0.34


    description: Grid {
        spacing: columns > 1 ? units.gu(2) : 0
        columns: preview.narrowMode || width < units.gu(60) ? 1 : 2
        property int columnWidth: columns > 1 ? (width - spacing * (columns - 1)) / columns : width
        anchors {
            left: parent.left
            right: parent.right
        }

        Status {
            id: status
            objectName: "statusField"
            width: parent.columnWidth
            visible: preview.model != undefined && preview.model.status != undefined
            model: preview.model
            property int index: 1
            // FIXME that should trigger the action on the lens/scope, when there's support
            onClicked: shell.activateApplication("/usr/share/applications/%1-webapp.desktop".arg(model.statusService), "--homepage=%1".arg(model.statusPostUri))
        }


        Column {
            id: descriptionColumn
            width: parent.columnWidth


            Column {
                anchors {
                    left: parent.left
                    right: parent.right
                }

                Repeater {
                    model: preview.model ? preview.model.phoneNumbers : undefined

                    delegate: Phone {
                        objectName: "phoneField" + index
                        model: preview.model
                        // FIXME these should trigger actions on the lens/scope, when there's support
                        onPhoneClicked: shell.activateApplication("/usr/share/applications/phone-app.desktop", "call://%1".arg(number.replace(/[^\d\+]/g, "")))
                        onTextClicked: shell.activateApplication("/usr/share/applications/phone-app.desktop", "message://%1".arg(number.replace(/[^\d\+]/g, "")))
                    }
                }
            }

            Column {
                anchors {
                    left: parent.left
                    right: parent.right
                }

                Repeater {
                    model: preview.model ? preview.model.emailAddresses : undefined
                    delegate: Generic {
                        objectName: "emailField" + index
                        type: "email"
                    }
                }
            }

            Column {
                anchors {
                    left: parent.left
                    right: parent.right
                }

                Repeater {
                    model: preview.model ? preview.model.imAccounts : undefined
                    delegate: Generic {
                        objectName: "imField" + index
                        type: "imAccount"
                    }
                }
            }

            Column {
                anchors {
                    left: parent.left
                    right: parent.right
                }

                Repeater {
                    model: preview.model ? preview.model.addresses : undefined
                    delegate: Address {
                        objectName: "addressField" + index
                    }
                }
            }
        }
    }
}
