/*
 * Copyright 2013,2015 Canonical Ltd.
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
 */

import QtQuick 2.0
import Ubuntu.Settings.Menus 0.1 as Menus
import Ubuntu.Settings.Components 0.1
import QMenuModel 0.1
import Utils 0.1 as Utils
import Ubuntu.Components.ListItems 0.1 as ListItems
import Ubuntu.Components 1.2
import Unity.Session 0.1

Item {
    id: menuFactory

    property var rootModel: null
    property var menuModel: null

    property var _map:  {
        "default": {
            "unity.widgets.systemsettings.tablet.volumecontrol" : sliderMenu,
            "unity.widgets.systemsettings.tablet.switch"        : switchMenu,

            "com.canonical.indicator.button"         : buttonMenu,
            "com.canonical.indicator.div"            : separatorMenu,
            "com.canonical.indicator.section"        : sectionMenu,
            "com.canonical.indicator.progress"       : progressMenu,
            "com.canonical.indicator.slider"         : sliderMenu,
            "com.canonical.indicator.switch"         : switchMenu,
            "com.canonical.indicator.alarm"          : alarmMenu,
            "com.canonical.indicator.appointment"    : appointmentMenu,
            "com.canonical.indicator.transfer"       : transferMenu,
            "com.canonical.indicator.button-section" : buttonSectionMenu,
            "com.canonical.indicator.link"           : linkMenu,

            "com.canonical.indicator.messages.messageitem"  : messageItem,
            "com.canonical.indicator.messages.sourceitem"   : groupedMessage,

            "com.canonical.unity.slider"    : sliderMenu,
            "com.canonical.unity.switch"    : switchMenu,

            "com.canonical.unity.media-player"    : mediaPayerMenu,
            "com.canonical.unity.playback-item"   : playbackItemMenu,

            "unity.widgets.systemsettings.tablet.wifisection" : wifiSection,
            "unity.widgets.systemsettings.tablet.accesspoint" : accessPoint,
            "com.canonical.indicator.network.modeminfoitem" : modeminfoitem,

            "com.canonical.indicator.calendar": calendarMenu,
            "com.canonical.indicator.location": timezoneMenu,

            "indicator.user-menu-item": userMenuItem,
            "indicator.guest-menu-item": userMenuItem
        },
        "indicator-messages" : {
            "com.canonical.indicator.button"         : messagesButtonMenu
        }
    }

    function getExtendedProperty(object, propertyName, defaultValue) {
        if (object && object.hasOwnProperty(propertyName)) {
            return object[propertyName];
        }
        return defaultValue;
    }

    Component {
        id: separatorMenu;

        Menus.SeparatorMenu {
            objectName: "separatorMenu"
        }
    }

    Component {
        id: sliderMenu;

        Menus.SliderMenu {
            id: sliderItem
            objectName: "sliderMenu"
            property QtObject menuData: null
            property var menuModel: menuFactory.menuModel
            property int menuIndex: -1
            property var extendedData: menuData && menuData.ext || undefined
            property var serverValue: getExtendedProperty(menuData, "actionState", undefined)

            text: menuData && menuData.label || ""
            iconSource: menuData && menuData.icon || ""
            minIcon: getExtendedProperty(extendedData, "minIcon", "")
            maxIcon: getExtendedProperty(extendedData, "maxIcon", "")

            minimumValue: getExtendedProperty(extendedData, "minValue", 0.0)
            maximumValue: {
                var maximum = getExtendedProperty(extendedData, "maxValue", 1.0);
                if (maximum <= minimumValue) {
                    return minimumValue + 1;
                }
                return maximum;
            }
            enabled: menuData && menuData.sensitive || false
            highlightWhenPressed: false

            onMenuModelChanged: {
                loadAttributes();
            }
            onMenuIndexChanged: {
                loadAttributes();
            }

            function loadAttributes() {
                if (!menuModel || menuIndex == -1) return;
                menuModel.loadExtendedAttributes(menuIndex, {'min-value': 'double',
                                                             'max-value': 'double',
                                                             'min-icon': 'icon',
                                                             'max-icon': 'icon'});
            }

            ServerPropertySynchroniser {
                objectName: "sync"
                syncTimeout: Utils.Constants.indicatorValueTimeout
                bufferedSyncTimeout: true
                maximumWaitBufferInterval: 16

                serverTarget: sliderItem
                serverProperty: "serverValue"
                userTarget: sliderItem
                userProperty: "value"

                onSyncTriggered: menuModel.changeState(menuIndex, value)
            }
        }
    }

    Component {
        id: buttonMenu;

        Menus.ButtonMenu {
            objectName: "buttonMenu"
            property QtObject menuData: null
            property var menuModel: menuFactory.menuModel
            property int menuIndex: -1

            buttonText: menuData && menuData.label || ""
            enabled: menuData && menuData.sensitive || false
            highlightWhenPressed: false

            onTriggered: {
                menuModel.activate(menuIndex);
            }
        }
    }

    Component {
        id: messagesButtonMenu;

        Item {
            objectName: "messagesButtonMenu"
            property QtObject menuData: null
            property var menuModel: menuFactory.menuModel
            property int menuIndex: -1

            implicitHeight: units.gu(5)
            enabled: menuData && menuData.sensitive || false

            Label {
                id: buttonMenuLabel
                text: menuData && menuData.label || ""
                anchors.centerIn: parent
                font.bold: true
            }

            MouseArea {
                anchors {
                    fill: buttonMenuLabel
                    margins: units.gu(-1)
                }
                onClicked: menuModel.activate(menuIndex);
            }
        }
    }

    Component {
        id: sectionMenu;

        Menus.SectionMenu {
            objectName: "sectionMenu"
            property QtObject menuData: null
            property var menuIndex: undefined

            text: menuData && menuData.label || ""
            busy: false
        }
    }

    Component {
        id: progressMenu;

        Menus.ProgressValueMenu {
            objectName: "progressMenu"
            property QtObject menuData: null
            property int menuIndex: -1

            text: menuData && menuData.label || ""
            iconSource: menuData && menuData.icon || ""
            value : menuData && menuData.actionState || 0.0
            enabled: menuData && menuData.sensitive || false
            highlightWhenPressed: false
        }
    }

    Component {
        id: standardMenu;

        Menus.StandardMenu {
            objectName: "standardMenu"
            property QtObject menuData: null
            property int menuIndex: -1

            text: menuData && menuData.label || ""
            iconSource: menuData && menuData.icon || ""
            enabled: menuData && menuData.sensitive || false
            highlightWhenPressed: false

            onTriggered: {
                menuModel.activate(menuIndex);
            }

            // FIXME : At the moment, the indicators aren't using
            // com.canonical.indicators.link for settings menu. Need to fudge it.
            property bool settingsMenu: menuData && menuData.action.indexOf("settings") > -1 || false
            backColor: settingsMenu ? Qt.rgba(1,1,1,0.07) : "transparent"
            component: settingsMenu ? buttonForSettings : undefined
            Component {
                id: buttonForSettings
                Icon {
                    name: "settings"
                    height: units.gu(3)
                    width: height
                    color: Theme.palette.selected.backgroundText
                }
            }
        }
    }

    Component {
        id: linkMenu;

        Menus.StandardMenu {
            objectName: "linkMenu"
            property QtObject menuData: null
            property int menuIndex: -1

            text: menuData && menuData.label || ""
            iconSource: menuData && menuData.icon || ""
            enabled: menuData && menuData.sensitive || false
            highlightWhenPressed: false

            onTriggered: {
                menuModel.activate(menuIndex);
            }

            backColor: Qt.rgba(1,1,1,0.07)

            component: menuData.icon ? icon : undefined
            Component {
                id: icon
                Icon {
                    source: menuData.icon
                    height: units.gu(3)
                    width: height
                    color: Theme.palette.selected.backgroundText
                }
            }
        }
    }

    Component {
        id: checkableMenu;

        Menus.CheckableMenu {
            id: checkItem
            objectName: "checkableMenu"
            property QtObject menuData: null
            property int menuIndex: -1
            property bool serverChecked: menuData && menuData.isToggled || false

            text: menuData && menuData.label || ""
            enabled: menuData && menuData.sensitive || false
            checked: serverChecked
            highlightWhenPressed: false

            ServerPropertySynchroniser {
                objectName: "sync"
                syncTimeout: Utils.Constants.indicatorValueTimeout

                serverTarget: checkItem
                serverProperty: "serverChecked"
                userTarget: checkItem
                userProperty: "checked"

                onSyncTriggered: menuModel.activate(checkItem.menuIndex)
            }
        }
    }

    Component {
        id: switchMenu;

        Menus.SwitchMenu {
            id: switchItem
            objectName: "switchMenu"
            property QtObject menuData: null
            property int menuIndex: -1
            property bool serverChecked: menuData && menuData.isToggled || false

            text: menuData && menuData.label || ""
            iconSource: menuData && menuData.icon || ""
            enabled: menuData && menuData.sensitive || false
            checked: serverChecked
            highlightWhenPressed: false

            ServerPropertySynchroniser {
                objectName: "sync"
                syncTimeout: Utils.Constants.indicatorValueTimeout

                serverTarget: switchItem
                serverProperty: "serverChecked"
                userTarget: switchItem
                userProperty: "checked"

                onSyncTriggered: menuModel.activate(switchItem.menuIndex);
            }
        }
    }

    Component {
        id: alarmMenu;

        Menus.EventMenu {
            objectName: "alarmMenu"
            property QtObject menuData: null
            property var menuModel: menuFactory.menuModel
            property int menuIndex: -1
            property var extendedData: menuData && menuData.ext || undefined
            // TODO - bug #1260728
            property var timeFormatter: Utils.GDateTimeFormatter {
                time: getExtendedProperty(extendedData, "xCanonicalTime", 0)
                format: getExtendedProperty(extendedData, "xCanonicalTimeFormat", "")
            }

            text: menuData && menuData.label || ""
            iconSource: menuData && menuData.icon || "image://theme/alarm-clock"
            time: timeFormatter.timeString
            enabled: menuData && menuData.sensitive || false
            highlightWhenPressed: false

            onMenuModelChanged: {
                loadAttributes();
            }
            onMenuIndexChanged: {
                loadAttributes();
            }
            onTriggered: {
                menuModel.activate(menuIndex);
            }

            function loadAttributes() {
                if (!menuModel || menuIndex == -1) return;
                menuModel.loadExtendedAttributes(menuIndex, {'x-canonical-time': 'int64',
                                                             'x-canonical-time-format': 'string'});
            }
        }
    }

    Component {
        id: appointmentMenu;

        Menus.EventMenu {
            objectName: "appointmentMenu"
            property QtObject menuData: null
            property var menuModel: menuFactory.menuModel
            property int menuIndex: -1
            property var extendedData: menuData && menuData.ext || undefined
            // TODO - bug #1260728
            property var timeFormatter: Utils.GDateTimeFormatter {
                time: getExtendedProperty(extendedData, "xCanonicalTime", 0)
                format: getExtendedProperty(extendedData, "xCanonicalTimeFormat", "")
            }

            text: menuData && menuData.label || ""
            iconSource: menuData && menuData.icon || "image://theme/calendar"
            time: timeFormatter.timeString
            eventColor: getExtendedProperty(extendedData, "xCanonicalColor", Qt.rgba(0.0, 0.0, 0.0, 0.0))
            enabled: menuData && menuData.sensitive || false
            highlightWhenPressed: false

            onMenuModelChanged: {
                loadAttributes();
            }
            onMenuIndexChanged: {
                loadAttributes();
            }
            onTriggered: {
                menuModel.activate(menuIndex);
            }

            function loadAttributes() {
                if (!menuModel || menuIndex == -1) return;
                menuModel.loadExtendedAttributes(menuIndex, {'x-canonical-color': 'string',
                                                             'x-canonical-time': 'int64',
                                                             'x-canonical-time-format': 'string'});
            }
        }
    }

    Component {
        id: userMenuItem

        Menus.UserSessionMenu {
            objectName: "userSessionMenu"
            highlightWhenPressed: false

            property QtObject menuData: null
            property var menuModel: menuFactory.menuModel
            property int menuIndex: -1

            name: menuData && menuData.label || "" // label is the user's real name
            iconSource: menuData && menuData.icon || ""

            // would be better to compare with the logname but sadly the indicator doesn't expose that
            active: DBusUnitySessionService.RealName() !== "" ? DBusUnitySessionService.RealName() == name
                                                              : DBusUnitySessionService.UserName() == name

            onTriggered: {
                menuModel.activate(menuIndex);
            }
        }
    }

    Component {
        id: calendarMenu

        Menus.CalendarMenu {
            objectName: "calendarMenu"
            highlightWhenPressed: false
            focus: true
        }
    }

    Component {
        id: timezoneMenu

        Menus.TimeZoneMenu {
            id: tzMenuItem
            objectName: "timezoneMenu"

            property QtObject menuData: null
            property var menuModel: menuFactory.menuModel
            property int menuIndex: -1
            property var extendedData: menuData && menuData.ext || undefined
            readonly property string tz: getExtendedProperty(extendedData, "xCanonicalTimezone", "UTC")
            property var updateTimer: Timer {
                repeat: true
                running: tzMenuItem.visible // only run when we're open
                onTriggered: tzMenuItem.time = Utils.TimezoneFormatter.currentTimeInTimezone(tzMenuItem.tz)
            }

            city: menuData && menuData.label || ""
            time: Utils.TimezoneFormatter.currentTimeInTimezone(tz)
            enabled: menuData && menuData.sensitive || false

            onMenuModelChanged: {
                loadAttributes();
            }
            onMenuIndexChanged: {
                loadAttributes();
            }
            onTriggered: {
                tzActionGroup.setLocation.activate(tz);
            }

            QDBusActionGroup {
                id: tzActionGroup
                busType: DBus.SessionBus
                busName: "com.canonical.indicator.datetime"
                objectPath: "/com/canonical/indicator/datetime"

                property variant setLocation: action("set-location")

                Component.onCompleted: tzActionGroup.start()
            }

            function loadAttributes() {
                if (!menuModel || menuIndex == -1) return;
                menuModel.loadExtendedAttributes(menuIndex, {'x-canonical-timezone': 'string'});
            }
        }
    }

    Component {
        id: wifiSection;

        Menus.SectionMenu {
            objectName: "wifiSection"
            property QtObject menuData: null
            property var menuModel: menuFactory.menuModel
            property int menuIndex: -1
            property var extendedData: menuData && menuData.ext || undefined

            text: menuData && menuData.label || ""
            busy: getExtendedProperty(extendedData, "xCanonicalBusyAction", false)

            onMenuModelChanged: {
                loadAttributes();
            }
            onMenuIndexChanged: {
                loadAttributes();
            }

            function loadAttributes() {
                if (!menuModel || menuIndex == -1) return;
                menuModel.loadExtendedAttributes(menuIndex, {'x-canonical-busy-action': 'bool'})
            }
        }
    }

    Component {
        id: accessPoint;

        Menus.AccessPointMenu {
            id: apItem
            objectName: "accessPoint"
            property QtObject menuData: null
            property var menuModel: menuFactory.menuModel
            property int menuIndex: -1
            property var extendedData: menuData && menuData.ext || undefined
            property bool serverChecked: menuData && menuData.isToggled || false

            property var strengthAction: UnityMenuAction {
                model: menuModel
                index: menuIndex
                name: getExtendedProperty(extendedData, "xCanonicalWifiApStrengthAction", "")
            }

            text: menuData && menuData.label || ""
            enabled: menuData && menuData.sensitive || false
            active: serverChecked
            secure: getExtendedProperty(extendedData, "xCanonicalWifiApIsSecure", false)
            adHoc: getExtendedProperty(extendedData, "xCanonicalWifiApIsAdhoc", false)
            signalStrength: strengthAction.valid ? strengthAction.state : 0
            highlightWhenPressed: false

            onMenuModelChanged: {
                loadAttributes();
            }
            onMenuIndexChanged: {
                loadAttributes();
            }

            function loadAttributes() {
                if (!menuModel || menuIndex == -1) return;
                menuModel.loadExtendedAttributes(menuIndex, {'x-canonical-wifi-ap-is-adhoc': 'bool',
                                                             'x-canonical-wifi-ap-is-secure': 'bool',
                                                             'x-canonical-wifi-ap-strength-action': 'string'});
            }

            ServerPropertySynchroniser {
                objectName: "sync"
                syncTimeout: Utils.Constants.indicatorValueTimeout

                serverTarget: apItem
                serverProperty: "serverChecked"
                userTarget: apItem
                userProperty: "active"
                userTrigger: "onTriggered"

                onSyncTriggered: menuModel.activate(apItem.menuIndex)
            }
        }
    }

    Component {
        id: modeminfoitem;
        ModemInfoItem {
            objectName: "modemInfoItem"
            property QtObject menuData: null
            property var menuModel: menuFactory.menuModel
            property int menuIndex: -1
            property var extendedData: menuData && menuData.ext || undefined
            highlightWhenPressed: false

            property var statusLabelAction: UnityMenuAction {
                model: menuModel
                index: menuIndex
                name: getExtendedProperty(extendedData, "xCanonicalModemStatusLabelAction", "")
            }
            statusText: statusLabelAction.valid ? statusLabelAction.state : ""

            property var statusIconAction: UnityMenuAction {
                model: menuModel
                index: menuIndex
                name: getExtendedProperty(extendedData, "xCanonicalModemStatusIconAction", "")
            }
            statusIcon: statusIconAction.valid ? statusIconAction.state : ""

            property var connectivityIconAction: UnityMenuAction {
                model: menuModel
                index: menuIndex
                name: getExtendedProperty(extendedData, "xCanonicalModemConnectivityIconAction", "")
            }
            connectivityIcon: connectivityIconAction.valid ? connectivityIconAction.state : ""

            property var simIdentifierLabelAction: UnityMenuAction {
                model: menuModel
                index: menuIndex
                name: getExtendedProperty(extendedData, "xCanonicalModemSimIdentifierLabelAction", "")
            }
            simIdentifierText: simIdentifierLabelAction.valid ? simIdentifierLabelAction.state : ""

            property var roamingAction: UnityMenuAction {
                model: menuModel
                index: menuIndex
                name: getExtendedProperty(extendedData, "xCanonicalModemRoamingAction", "")
            }
            roaming: roamingAction.valid ? roamingAction.state : false

            property var unlockAction: UnityMenuAction {
                model: menuModel
                index: menuIndex
                name: getExtendedProperty(extendedData, "xCanonicalModemLockedAction", "")
            }
            onUnlock: {
                unlockAction.activate();
            }
            locked: unlockAction.valid ? unlockAction.state : false

            onMenuModelChanged: {
                loadAttributes();
            }
            onMenuIndexChanged: {
                loadAttributes();
            }

            function loadAttributes() {
                if (!menuModel || menuIndex == -1) return;
                menuModel.loadExtendedAttributes(menuIndex, {'x-canonical-modem-status-label-action': 'string',
                                                             'x-canonical-modem-status-icon-action': 'string',
                                                             'x-canonical-modem-connectivity-icon-action': 'string',
                                                             'x-canonical-modem-sim-identifier-label-action': 'string',
                                                             'x-canonical-modem-roaming-action': 'string',
                                                             'x-canonical-modem-locked-action': 'string'});
            }
        }
    }

    Component {
        id: messageItem

        MessageMenuItemFactory {
            objectName: "messageItem"
            menuModel: menuFactory.menuModel
        }
    }

    Component {
        id: groupedMessage

        Menus.GroupedMessageMenu {
            objectName: "groupedMessage"
            property QtObject menuData: null
            property var menuModel: menuFactory.menuModel
            property int menuIndex: -1
            property var extendedData: menuData && menuData.ext || undefined

            text: menuData && menuData.label || ""
            iconSource: getExtendedProperty(extendedData, "icon", "image://theme/message")
            count: menuData && menuData.actionState.length > 0 ? menuData.actionState[0] : "0"
            enabled: menuData && menuData.sensitive || false
            highlightWhenPressed: false
            removable: true

            onMenuModelChanged: {
                loadAttributes();
            }
            onMenuIndexChanged: {
                loadAttributes();
            }
            onClicked: {
                menuModel.activate(menuIndex, true);
            }
            onDismissed: {
                menuModel.activate(menuIndex, false);
            }

            function loadAttributes() {
                if (!menuModel || menuIndex == -1) return;
                menuModel.loadExtendedAttributes(modelIndex, {'icon': 'icon'});
            }
        }
    }

    Component {
        id: mediaPayerMenu;

        Menus.MediaPlayerMenu {
            objectName: "mediaPayerMenu"
            property QtObject menuData: null
            property var menuModel: menuFactory.menuModel
            property int menuIndex: -1
            property var actionState: menuData && menuData.actionState || undefined
            property bool running: getExtendedProperty(actionState, "running", false)

            playerIcon: menuData && menuData.icon || "image://theme/stock_music"
            playerName: menuData && menuData.label || i18n.tr("Nothing is playing")

            albumArt: getExtendedProperty(actionState, "art-url", "image://theme/stock_music")
            song: getExtendedProperty(actionState, "title", "")
            artist: getExtendedProperty(actionState, "artist", "")
            album: getExtendedProperty(actionState, "album", "")
            showTrack: running && (state == "Playing" || state == "Paused")
            state: getExtendedProperty(actionState, "state", "")
            enabled: menuData && menuData.sensitive || false
            highlightWhenPressed: false
            showDivider: false

            onTriggered: {
                model.activate(modelIndex);
            }
        }
    }

    Component {
        id: playbackItemMenu;

        Menus.PlaybackItemMenu {
            objectName: "playbackItemMenu"
            property QtObject menuData: null
            property var menuModel: menuFactory.menuModel
            property int menuIndex: -1
            property var extendedData: menuData && menuData.ext || undefined

            property var playAction: UnityMenuAction {
                model: menuModel
                index: menuIndex
                name: getExtendedProperty(extendedData, "xCanonicalPlayAction", "")
            }
            property var nextAction: UnityMenuAction {
                model: menuModel
                index: menuIndex
                name: getExtendedProperty(extendedData, "xCanonicalNextAction", "")
            }
            property var previousAction: UnityMenuAction {
                model: menuModel
                index: menuIndex
                name: getExtendedProperty(extendedData, "xCanonicalPreviousAction", "")
            }

            playing: playAction.state === "Playing"
            canPlay: playAction.valid
            canGoNext: nextAction.valid
            canGoPrevious: previousAction.valid
            enabled: menuData && menuData.sensitive || false
            highlightWhenPressed: false

            onPlay: {
                playAction.activate();
            }
            onNext: {
                nextAction.activate();
            }
            onPrevious: {
                previousAction.activate();
            }
            onMenuModelChanged: {
                loadAttributes();
            }
            onMenuIndexChanged: {
                loadAttributes();
            }

            function loadAttributes() {
                if (!menuModel || menuIndex == -1) return;
                menuModel.loadExtendedAttributes(modelIndex, {'x-canonical-play-action': 'string',
                                                              'x-canonical-next-action': 'string',
                                                              'x-canonical-previous-action': 'string'});
            }
        }
    }

    Component {
        id: transferMenu

        Menus.TransferMenu {
            objectName: "transferMenu"
            id: transfer
            property QtObject menuData: null
            property var menuModel: menuFactory.menuModel
            property int menuIndex: -1
            property var extendedData: menuData && menuData.ext || undefined
            property var uid: getExtendedProperty(extendedData, "xCanonicalUid", undefined)

            text: menuData && menuData.label || ""
            iconSource: menuData && menuData.icon || "image://theme/transfer-none"
            maximum: 1.0
            enabled: menuData && menuData.sensitive || false
            highlightWhenPressed: false
            removable: true
            confirmRemoval: true

            QDBusActionGroup {
                id: actionGroup
                busType: 1
                busName: rootModel.busName
                objectPath: rootModel.actions["indicator"]

                property var activateAction: action("activate-transfer")
                property var cancelAction: action("cancel-transfer")
                property var transferStateAction: uid !== undefined ? action("transfer-state."+uid) : null

                Component.onCompleted: actionGroup.start()
            }

            property var transferState: {
                if (actionGroup.transferStateAction === null) return undefined;
                return actionGroup.transferStateAction.valid ? actionGroup.transferStateAction.state : undefined
            }

            property var runningState : transferState !== undefined ? transferState["state"] : undefined
            property var secondsLeft : transferState !== undefined ? transferState["seconds-left"] : undefined

            active: runningState !== undefined && runningState !== Menus.TransferState.Finished
            progress: transferState !== undefined ? transferState["percent"] : 0.0

            // TODO - Should be in the SDK
            property var timeRemaining: {
                if (secondsLeft === undefined) return undefined;

                var remaining = "";
                var hours = Math.floor(secondsLeft / (60 * 60));
                var minutes = Math.floor(secondsLeft / 60) % 60;
                var seconds = secondsLeft % 60;
                if (hours > 0) {
                    remaining += i18n.tr("%1 hour", "%1 hours", hours).arg(hours)
                }
                if (minutes > 0) {
                    if (remaining != "") remaining += ", ";
                    remaining += i18n.tr("%1 minute", "%1 minutes", minutes).arg(minutes)
                }
                // don't include seconds if hours > 0
                if (hours == 0 && minutes < 5 && seconds > 0) {
                    if (remaining != "") remaining += ", ";
                    remaining += i18n.tr("%1 second", "%1 seconds", seconds).arg(seconds)
                }
                if (remaining == "")
                    remaining = i18n.tr("0 seconds");
                // Translators: String like "1 hour, 2 minutes, 3 seconds remaining"
                return i18n.tr("%1 remaining").arg(remaining);
            }

            stateText: {
                switch (runningState) {
                    case Menus.TransferState.Queued:
                        return i18n.tr("In queue…");
                    case Menus.TransferState.Hashing:
                    case Menus.TransferState.Processing:
                    case Menus.TransferState.Running:
                        return timeRemaining === undefined ? i18n.tr("Downloading") : timeRemaining;
                    case Menus.TransferState.Paused:
                        return i18n.tr("Paused, tap to resume");
                    case Menus.TransferState.Canceled:
                        return i18n.tr("Canceled");
                    case Menus.TransferState.Finished:
                        return i18n.tr("Finished");
                    case Menus.TransferState.Error:
                        return i18n.tr("Failed, tap to retry");
                }
                return "";
            }

            onMenuModelChanged: {
                loadAttributes();
            }
            onMenuIndexChanged: {
                loadAttributes();
            }
            onTriggered: {
                actionGroup.activateAction.activate(uid);
            }
            onItemRemoved: {
                actionGroup.cancelAction.activate(uid);
            }

            function loadAttributes() {
                if (!menuModel || menuIndex == -1) return;
                menuModel.loadExtendedAttributes(menuIndex, {'x-canonical-uid': 'string'});
            }
        }
    }

    Component {
        id: buttonSectionMenu;

        Menus.StandardMenu {
            objectName: "buttonSectionMenu"
            property QtObject menuData: null
            property var menuModel: menuFactory.menuModel
            property int menuIndex: -1
            property var extendedData: menuData && menuData.ext || undefined

            iconSource: menuData && menuData.icon || ""
            enabled: menuData && menuData.sensitive || false
            highlightWhenPressed: false
            text: menuData && menuData.label || ""
            foregroundColor: Theme.palette.normal.backgroundText

            onMenuModelChanged: {
                loadAttributes();
            }
            onMenuIndexChanged: {
                loadAttributes();
            }
            function loadAttributes() {
                if (!menuModel || menuIndex == -1) return;
                menuModel.loadExtendedAttributes(menuIndex, {'x-canonical-extra-label': 'string'});
            }

            component: Component {
                Button {
                    objectName: "buttonSectionMenuControl"
                    text: getExtendedProperty(extendedData, "xCanonicalExtraLabel", "")

                    onClicked: {
                        menuModel.activate(menuIndex);
                    }
                }
            }
        }
    }

    function load(modelData, context) {
        if (modelData.type !== undefined && modelData.type !== "") {
            var component = undefined;

            var contextComponents = _map[context];
            if (contextComponents !== undefined) {
                component = contextComponents[modelData.type];
            }

            if (component === undefined) {
                component = _map["default"][modelData.type];
            }
            if (component !== undefined) {
                return component;
            }
            console.debug("Don't know how to make " + modelData.type + " for " + context);
        }
        if (modelData.isCheck || modelData.isRadio) {
            return checkableMenu;
        }
        if (modelData.isSeparator) {
            return separatorMenu;
        }
        return standardMenu;
    }
}
