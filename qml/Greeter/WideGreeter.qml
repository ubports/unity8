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

import QtQuick 2.3
import LightDM 0.1 as LightDM
import Ubuntu.Components 1.1

Item {
    id: root

    property alias dragHandleLeftMargin: coverPage.dragHandleLeftMargin
    property alias launcherOffset: coverPage.launcherOffset
    property alias currentIndex: loginList.currentIndex
    property int delayMinutes // TODO
    property alias backgroundTopMargin: coverPage.backgroundTopMargin
    property bool fullyShown: coverPage.showProgress === 1
    property bool required: coverPage.required

    signal selected(int index)
    signal unlocked()
    signal tease()

    function showMessage(html) {
        loginList.showMessage(html);
    }

    function showPrompt(text, isSecret, isDefaultPrompt) {
        loginList.showPrompt(text, isSecret, isDefaultPrompt);
    }

    function showLastChance() {
        // TODO
    }

    function hide() {
        coverPage.hide();
    }

    function authenticated(success) {
        if (!success) {
            loginList.showError();
        }
    }

    function reset() {
        loginList.reset();
    }

    function tryToUnlock(toTheRight) {
        if (LightDM.Greeter.authenticated) {
            if (toTheRight) {
                coverPage.hideRight();
            } else {
                coverPage.hide();
            }
        } else {
            coverPage.show();
            loginList.tryToUnlock();
        }
    }

    QtObject {
        id: d
    }

    Rectangle {
        anchors.fill: parent
        color: "black"
        opacity: coverPage.showProgress * 0.8
    }

    CoverPage {
        id: coverPage
        objectName: "coverPage"
        height: parent.height
        width: parent.width
        background: greeter.background
        draggable: !greeter.locked

        infographics {
            height: 0.75 * parent.height
            anchors.leftMargin: loginList.x + loginList.width
        }

        onTease: root.tease()

        onShowProgressChanged: {
            if (showProgress === 0 && !greeter.locked) {
                root.unlocked();
            }
        }
    }

    LoginList {
        id: loginList
        objectName: "loginList"

        anchors {
            left: parent.left
            leftMargin: Math.min(parent.width * 0.16, units.gu(20))
            verticalCenter: parent.verticalCenter
        }
        width: units.gu(29)
        height: parent.height

        model: LightDM.Users

        onSelected: root.selected(uid)
        onUnlocked: coverPage.hide()
    }
}
