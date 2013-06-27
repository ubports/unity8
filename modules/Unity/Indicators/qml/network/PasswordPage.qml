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
 */

import QtQuick 2.0
import Ubuntu.Components 0.1
import Ubuntu.Components.ListItems 0.1 as ListItem
import Unity.Indicators 0.1 as Indicators

Page {
    id: pagePassword

    property variant agent
    property variant token

    anchors.fill: parent
    title: "Network Authentication"

    Column {
        anchors {
            left: parent.left
            right: parent.right
        }

        Indicators.SectionMenu {
            label: "Authentication"
        }

        Indicators.TextMenu {
            id: _password

            password: true
        }

        Indicators.Menu {
            Row {
                anchors {
                    right: parent.right
                    verticalCenter: parent.verticalCenter
                    margins: units.gu(3)
                }

                spacing: units.gu(1)

                Button {
                    text: "Cancel"
                    width: units.gu(10)
                    onClicked: {
                        agent.cancel(token);
                        pageStack.pop();
                    }
                }

                Button {
                    text: "Ok"
                    width: units.gu(10)
                    onClicked: {
                        agent.authenticate(token, _password.text);
                        pageStack.pop();
                    }
                }
            }
        }
    }
}
