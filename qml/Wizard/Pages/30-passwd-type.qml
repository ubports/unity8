/*
 * Copyright (C) 2014,2015 Canonical, Ltd.
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
import Ubuntu.Components.ListItems 1.3
import Ubuntu.SystemSettings.SecurityPrivacy 1.0
import ".." as LocalComponents

/**
 * One quirk with this page: we don't actually set the password.  We avoid
 * doing it here because the user can come back to this page and change their
 * answer.  We don't run as root, so if we did set the password immediately,
 * we'd need to prompt for their previous password when they came back and
 * changed their answer.  Which is silly UX.  So instead, we just keep track
 * of their choice and set the password at the end (see main.qml).
 * Setting the password shouldn't fail, since Ubuntu Touch has loose password
 * requirements, but we'll check what we can here.  Ideally we'd be able to ask
 * the system if a password is legal without actually setting that password.
 */

LocalComponents.Page {
    id: passwdPage
    objectName: "passwdPage"

    title: i18n.tr("Lock security")
    forwardButtonSourceComponent: forwardButton

    // If the user has set a password some other way (via ubuntu-device-flash
    // or this isn't the first time the wizard has been run, etc).  We can't
    // properly set the password again, so let's not pretend we can.
    skip: securityPrivacy.securityType !== UbuntuSecurityPrivacyPanel.Swipe

    function indexToMethod(index) {
        if (index === 0)
            return UbuntuSecurityPrivacyPanel.Swipe
        else if (index === 1)
            return UbuntuSecurityPrivacyPanel.Passcode
        else
            return UbuntuSecurityPrivacyPanel.Passphrase
    }

    function methodToIndex(method) {
        if (method === UbuntuSecurityPrivacyPanel.Swipe)
            return 0
        else if (method === UbuntuSecurityPrivacyPanel.Passcode)
            return 1
        else
            return 2
    }

    Connections {
        target: root
        onPasswordMethodChanged: selector.selectedIndex = methodToIndex(root.passwordMethod)
    }

    Column {
        id: column
        anchors.fill: content
        spacing: units.gu(4)

        Label {
            anchors.left: parent.left
            anchors.right: parent.right
            wrapMode: Text.Wrap
            text: i18n.tr("Please select how you’d like to unlock your phone.")
        }

        ItemSelector {
            id: selector
            expanded: true
            anchors.left: parent.left
            anchors.right: parent.right
            property color originalBackground

            model: ["", "", ""] // otherwise the delegate will show the text itself and we only want subText

            selectedIndex: methodToIndex(root.passwordMethod)

            delegate: OptionSelectorDelegate {
                objectName: "passwdDelegate" + index

                // use subText because we want the text to be small, and we have no other way to control it
                subText: {
                    var method = indexToMethod(index)
                    var name = ""
                    var desc = ""
                    if (method === UbuntuSecurityPrivacyPanel.Swipe) {
                        name = i18n.ctr("Label: Type of security method", "Swipe")
                        desc = i18n.ctr("Label: Description of security method", "No security")
                    } else if (method === UbuntuSecurityPrivacyPanel.Passcode) {
                        name = i18n.ctr("Label: Type of security method", "Passcode")
                        desc = i18n.ctr("Label: Description of security method", "4 digits only")
                    } else {
                        name = i18n.ctr("Label: Type of security method", "Passphrase")
                        desc = i18n.ctr("Label: Description of security method", "Numbers and letters")
                    }
                    return "<b>%1</b> (%2)".arg(name).arg(desc)
                }
            }

            style: Item {}

            Component.onCompleted: {
                // A visible selected background looks bad in ListItem widgets with our theme
                originalBackground = theme.palette.selected.background
                theme.palette.selected.background = "transparent"
            }

            Component.onDestruction: {
                // Restore original theme background
                theme.palette.selected.background = originalBackground
            }
        }
    }

    Component {
        id: forwardButton
        LocalComponents.StackButton {
            text: i18n.tr("Continue")
            onClicked: {
                root.passwordMethod = indexToMethod(selector.selectedIndex)
                pageStack.load(Qt.resolvedUrl("passwd-set.qml"))
            }
        }
    }
}
