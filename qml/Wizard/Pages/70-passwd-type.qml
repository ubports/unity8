/*
 * Copyright (C) 2014-2015 Canonical, Ltd.
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

import QtQuick 2.3
import Ubuntu.Components 1.2
import Ubuntu.SystemSettings.SecurityPrivacy 1.0
import ".." as LocalComponents

/**
 * One quirk with this page: we don't actually set the password.  We avoid
 * doing it here because the user can come back to this page and change their
 * answer.  We don't run as root, so if we did set the password immediately,
 * we'd need to prompt for their previous password when they came back and
 * changed their answer.  Which is silly UX.  So instead, we just keep track
 * of their choice and set the password at the end (see Pages.qml).
 * Setting the password shouldn't fail, since Ubuntu Touch has loose password
 * requirements, but we'll check what we can here.  Ideally we'd be able to ask
 * the system if a password is legal without actually setting that password.
 */

LocalComponents.Page {
    id: passwdPage
    objectName: "passwdPage"

    title: i18n.tr("Lock Screen")
    forwardButtonSourceComponent: forwardButton

    function indexToMethod(index) {
        if (index === 1)
            return UbuntuSecurityPrivacyPanel.Passcode;
        else if (index === 0)
            return UbuntuSecurityPrivacyPanel.Passphrase;
        else
            return UbuntuSecurityPrivacyPanel.Swipe;
    }

    function methodToIndex(method) {
        if (method === UbuntuSecurityPrivacyPanel.Passcode)
            return 1;
        else if (method === UbuntuSecurityPrivacyPanel.Passphrase)
            return 0;
        else
            return 2;
    }

    Component.onCompleted: {
        selector.currentIndex = methodToIndex(root.passwordMethod);
    }

    Item {
        id: column
        anchors.fill: content
        anchors.topMargin: units.gu(4)

        Label {
            id: infoLabel
            anchors.left: parent.left
            anchors.right: parent.right
            wrapMode: Text.Wrap
            text: i18n.tr("Choose lock screen security")
            color: textColor
            fontSize: "small"
            font.weight: Font.Light
        }

        Rectangle {
            id: divider
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.top: infoLabel.bottom
            anchors.topMargin: units.gu(3)
            height: units.dp(1)
            color: dividerColor
        }

        ListView {
            id: selector
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.top: divider.bottom
            boundsBehavior: Flickable.StopAtBounds
            clip: true
            height: childrenRect.height

            // this is the order we want to display it; cf indexToMethod()
            model: [UbuntuSecurityPrivacyPanel.Passphrase, UbuntuSecurityPrivacyPanel.Passcode, UbuntuSecurityPrivacyPanel.Swipe]

            delegate: ListItem {
                id: itemDelegate
                readonly property bool isCurrent: index === ListView.view.currentIndex
                highlightColor: backgroundColor
                divider.colorFrom: dividerColor
                divider.colorTo: backgroundColor
                Label {
                    id: methodLabel
                    objectName: "passwdDelegate" + index
                    anchors.verticalCenter: parent.verticalCenter;
                    fontSize: "medium"
                    color: textColor
                    font.weight: itemDelegate.isCurrent ? Font.Normal : Font.Light
                    text: {
                        var method = modelData
                        var name = ""
                        var desc = ""
                        if (method === UbuntuSecurityPrivacyPanel.Swipe) {
                            return i18n.ctr("Label: Type of security method", "None");
                        } else if (method === UbuntuSecurityPrivacyPanel.Passcode) {
                            name = i18n.ctr("Label: Type of security method", "Passcode");
                            desc = i18n.ctr("Label: Description of security method", "4 digits only");
                        } else {
                            name = i18n.ctr("Label: Type of security method", "Password");
                            desc = i18n.ctr("Label: Description of security method", "numbers and letters");
                        }
                        return "%1 (%2)".arg(name).arg(desc);
                    }
                }

                Image {
                    anchors {
                        right: parent.right;
                        verticalCenter: parent.verticalCenter;
                    }
                    fillMode: Image.PreserveAspectFit
                    height: methodLabel.paintedHeight

                    source: "data/Tick@30.png"
                    visible: itemDelegate.isCurrent
                }

                onClicked: {
                    selector.currentIndex = index;
                    print("Current method: " + indexToMethod(index));
                }
            }
        }

        Rectangle {
            id: divider2
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.top: selector.bottom
            height: units.dp(1)
            color: dividerColor
        }
    }

    Component {
        id: forwardButton
        LocalComponents.StackButton {
            text: i18n.tr("Next")
            onClicked: {
                var method = indexToMethod(selector.currentIndex);
                root.passwordMethod = method;
                print("Current method: " + root.passwordMethod);

                if (method === UbuntuSecurityPrivacyPanel.Passphrase) {
                    pageStack.load(Qt.resolvedUrl("password-set.qml"));
                } else if (method === UbuntuSecurityPrivacyPanel.Passcode) {
                    pageStack.load(Qt.resolvedUrl("passcode-set.qml"));
                } else {
                    pageStack.next();
                }
            }
        }
    }
}
